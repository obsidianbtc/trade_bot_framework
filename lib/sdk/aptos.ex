defmodule Sdk.Aptos do
  require Logger
  require Req

  @endpoint "http://priv-trade-sdk.onrender.com"

  @doc """
  Removes a bid from a collection.

  ## Parameters

  - `bid`: The bid identifier to be removed.

  ## Returns

  - `:ok` tuple with the response body if the transaction succeeded.
  - `:error` tuple with the VM status if the transaction failed.
  """
  def remove_collection_bid(bid, wallet) do
    Logger.info("remove_collection_bid() => ")
    post_to_apt("/apt/removeCollectionBid", %{bid: bid, wallet: wallet})
  end

  @doc """
  Creates a bid for a collection.

  ## Parameters

  - `collection_id`: The identifier of the collection to bid on.
  - `bid_amount`: The amount of the bid.
  - `num_of_bids`: The number of bids to be placed.

  ## Returns

  - `:ok` tuple with the response body if the transaction succeeded.
  - `:error` tuple with the VM status if the transaction failed.
  """
  def create_collection_bid(collection_id, bid_amount, num_of_bids, wallet) do
    Logger.info("create_collection_bid() => ")

    post_to_apt("/apt/createCollectionBid", %{
      collectionId: collection_id,
      bidAmount: bid_amount,
      numOfBids: num_of_bids,
      wallet: wallet
    })
  end

  @doc """
  Lists an NFT for sale with a specified price.

  ## Parameters

  - `nft`: The NFT identifier to be listed.
  - `price`: The price at which the NFT should be listed.

  ## Returns

  - `:ok` tuple with the response body if the transaction succeeded.
  - `:error` tuple with the VM status if the transaction failed.
  """
  def list_nft(nft, price, wallet) do
    Logger.info("list_nft() =>")
    post_to_apt("/apt/listNft", %{nft: nft, price: price, wallet: wallet})
  end

  @doc false
  defp post_to_apt(path, payload) do
    headers = [{"Content-Type", "application/json"}]
    url = @endpoint <> path

    case Req.post(url, json: payload, headers: headers) do
      {:ok, %Req.Response{body: %{"success" => true} = response_body}} ->
        Logger.info("Transaction Succeeded:")
        {:ok, response_body}

      {:ok, %Req.Response{body: %{"success" => false} = response_body}} ->
        Logger.info("Transaction Failed:")
        {:error, response_body["vm_status"]}

      {:ok, %Req.Response{status: status, body: %{"error" => error_message}}}
      when status in [400, 500] ->
        Logger.error("Bad Request (#{status}): #{error_message}")
        {:error, error_message}

      {:error, error} ->
        Logger.error("Error during operation: #{inspect(error)}")
        {:error, error}
    end
  end
end
