defmodule Strategy.CollectionFloor.Pipeline do
  require Logger
  alias Utils.ProfitCalc, as: ProfitCalc

  @doc """
    Orchestrates the pipeline process for a given collection on a specific blockchain.

    This function takes a map with the keys `:chain`, `:wallet`, and `:collection_id`
    and performs the following steps:

    1. Fetch the trade data associated with the given `chain`, `wallet`, and `collection_id`.
    2. Match the current state of the wallet with respect to the collection.
    3. Decide the next action based on the current state.
    4. Call the appropriate function in the SDK to perform the action.

    ## Parameters

    - `%{chain: chain, wallet: wallet, collection_id: collection_id}`: A map where:
      - `:chain` is a string representing the blockchain network.
      - `:wallet` is a string representing the wallet address.
      - `:collection_id` is a string representing the unique identifier for the collection.

    ## Examples

        iex> Strategy.CollectionFloor.Pipeline.pipeline(%{
        ...>   chain: "aptos",
        ...>   collection_id: "22cd6470-b924-46a9-985f-4e1f91b85071",
        ...>   wallet: "0xde41b5b59fa9320a5067c0ff36179a7188e83a01bdb7815568eedaef2dcc93ed"
        ...> })
        {:ok, "No action taken"}


  """
  def pipeline(%{chain: chain, wallet: wallet, collection_id: collection_id}) do
    get_trade_data(chain, wallet, collection_id)
    |> match_current_state
    |> decide_action
    |> call_sdk(chain, wallet)
  end

  @doc """
    Fetches trade data for a given collection from the blockchain.

    This function takes the blockchain `chain`, the `wallet` address, and the `collection_id`
    and queries the indexer for the relevant trade data. It then extracts and structures the
    data into a map that includes the user's NFTs, bids, and the collection's bids and listings.
    It also identifies the highest bid and the floor listing for the collection.

    ## Parameters

    - `chain`: The blockchain network as a string.
    - `wallet`: The wallet address as a string.
    - `collection_id`: The unique identifier for the collection as a string.

    ## Returns

    A map containing:
      - `:chain` - The blockchain network.
      - `:wallet` - The wallet address.
      - `:collection_id` - The collection identifier.
      - `:my_nfts` - A list of NFTs owned by the wallet.
      - `:my_bids` - A list of bids placed by the wallet.
      - `:collection_bids` - A list of bids for the collection.
      - `:collection_listings` - A list of listings for the collection.
      - `:collection_info` - A map containing:
        - `:highest_bid` - The highest bid for the collection.
        - `:floor_listing` - The floor listing for the collection.

    ## Examples

        iex> Strategy.CollectionFloor.Pipeline.get_trade_data("aptos", "0xde41b5b59fa9320a5067c0ff36179a7188e83a01bdb7815568eedaef2dcc93ed", "22cd6470-b924-46a9-985f-4e1f91b85071")
        %{
          chain: "aptos",
          wallet: "0xde41b5b59fa9320a5067c0ff36179a7188e83a01bdb7815568eedaef2dcc93ed",
          collection_id: "22cd6470-b924-46a9-985f-4e1f91b85071",
          my_nfts: [...],
          my_bids: [...],
          collection_bids: [...],
          collection_listings: [...],
          collection_info: %{
            highest_bid: %{...},
            floor_listing: %{...}
          }
        }
  """
  def get_trade_data(chain, wallet, collection_id) do
    {:ok, %{"aptos" => data}} =
      Indexer.Api.build_trade_query(collection_id, wallet)
      |> Indexer.Api.execute_graphql_query()

    %{
      "nfts" => my_nfts,
      "bids" => my_bids,
      "collections" => [%{"bids" => collection_bids}],
      "listings" => collection_listings
    } = data

    highest_bid = hd(collection_bids)
    floor_listing = hd(collection_listings)

    %{
      chain: chain,
      wallet: wallet,
      collection_id: collection_id,
      my_nfts: my_nfts,
      my_bids: my_bids,
      collection_bids: collection_bids,
      collection_listings: collection_listings,
      collection_info: %{
        highest_bid: highest_bid,
        floor_listing: floor_listing
      }
    }
  end

  defp match_current_state(args) do
    cond do
      # TODO - in this scenario, you should remove the bids
      args.my_nfts != [] and args.my_bids != [] ->
        {:error, args}

      args.my_nfts != [] ->
        {:nfts, args}

      args.my_bids != [] ->
        {:bids, args}

      args.my_bids == [] and args.my_nfts == [] ->
        {:empty, args}

      true ->
        {:error, args}
    end
  end

  def decide_action({:empty, args}) do
    [bid1, _bid2] = args.collection_bids

    profitable_bid? =
      ProfitCalc.check_profit(
        args.chain,
        args.collection_id,
        args.collection_info.floor_listing["price"],
        bid1["price"] + 1
      )

    case profitable_bid? do
      true ->
        {:create_collection_bid, {args.collection_id, bid1["price"] + 1, 1}}

      false ->
        {:no_action}
    end
  end

  def decide_action({:nfts, args}) do
    # Is the NFt listed?
    my_nft = hd(args.my_nfts)
    acquisition_cost = nft_acquisition_cost(my_nft["actions"])

    nft_listed? = my_nft["listed"]

    floor_profitable? =
      ProfitCalc.check_profit(
        args.chain,
        args.collection_id,
        args.collection_info.floor_listing["price"],
        acquisition_cost
      )

    below_floor_profitable? =
      ProfitCalc.check_profit(
        args.chain,
        args.collection_id,
        args.collection_info.floor_listing["price"] - 1,
        acquisition_cost
      )

    floor_nft? = args.wallet == args.collection_info.floor_listing["seller"]

    raise_nft? = Enum.at(args.collection_listings, 1)["price"] - 1 > my_nft["price"]

    case {nft_listed?, floor_profitable?, floor_nft?, below_floor_profitable?, raise_nft?} do
      {false, false, _, _, _} ->
        {:no_action}

      {false, true, _, true, _} ->
        {:list_nft, {my_nft, args.collection_info.floor_listing["price"] - 1}}

      {false, true, _, false, _} ->
        {:list_nft, {my_nft, args.collection_info.floor_listing["price"]}}

      {true, false, _, _, _} ->
        {:no_action}

      {true, true, false, true, _} ->
        {:list_nft, {my_nft, args.collection_info.floor_listing["price"] - 1}}

      {true, true, false, false, _} ->
        {:list_nft, {my_nft, args.collection_info.floor_listing["price"]}}

      {true, true, true, _, true} ->
        {:list_nft, {my_nft, Enum.at(args.collection_listings, 1)["price"] - 1}}

      {true, _, true, _, false} ->
        {:no_action}
    end
  end

  def decide_action({:bids, args}) do
    current_bid = hd(args.my_bids)
    [bid1, bid2] = args.collection_bids

    profitable_bid? =
      ProfitCalc.check_profit(
        args.chain,
        args.collection_id,
        args.collection_info.floor_listing["price"],
        current_bid["price"]
      )

    highest_bid? = args.wallet == args.collection_info.highest_bid["bidder"]

    lower_bid? = bid1["price"] > bid2["price"] + 1

    case {profitable_bid?, highest_bid?, lower_bid?} do
      {false, _, _} ->
        {:remove_collection_bid, current_bid}

      {true, false, _} ->
        {:remove_collection_bid, current_bid}

      {true, true, true} ->
        {:remove_collection_bid, current_bid}

      {true, true, false} ->
        {:no_action}
    end
  end

  def decide_action({:error, args}) do
    Logger.error("Error in deciding action #{inspect(args, pretty: true)}")
    {:no_action}
  end

  def call_sdk({:no_action}, _chain, _wallet) do
    {:ok, "No action taken"}
  end

  def call_sdk({:create_collection_bid, {collection_id, bid_amount, num_of_bids}}, chain, wallet) do
    chain_module(chain).create_collection_bid(collection_id, bid_amount, num_of_bids, wallet)
  end

  def call_sdk({:list_nft, {nft, price}}, chain, wallet) do
    chain_module(chain).list_nft(nft, price, wallet)
  end

  def call_sdk({:remove_collection_bid, bid}, chain, wallet) do
    chain_module(chain).remove_collection_bid(bid, wallet)
  end

  defp nft_acquisition_cost(actions) do
    actions
    |> Enum.filter(
      &(&1["type"] in ["buy", "mint", "accept-collection-bid", "accept-solo-bid"] and
          Map.has_key?(&1, "price"))
    )
    |> Enum.map(&update_action_block_time/1)
    |> Enum.max_by(& &1["block_time"])
    |> Map.get("price")
  end

  defp update_action_block_time(action) do
    case DateTime.from_iso8601(action["block_time"]) do
      {:ok, datetime, _} -> Map.put(action, "block_time", datetime)
      {:error, _} -> action
    end
  end

  defp chain_module(chain) do
    Module.concat(Sdk, String.to_atom(String.capitalize(chain)))
  end
end
