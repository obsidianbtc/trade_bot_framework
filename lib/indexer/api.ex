defmodule Indexer.Api do
  require Logger
  require Req

  @x_api_user "insert_user_here"
  @x_api_key "insert_api_key"

  @doc """
  Executes a GraphQL query using the indexer.xyz API.

  ## Parameters

  - `%{query: query, variables: variables}`: A map containing the `:query` key with the GraphQL query string and
    the `:variables` key with a map of variables for the query.

  ## Returns

  - `{:ok, body}`: A tuple containing `:ok` and the response body if the request is successful and the HTTP status is 200.
  - `{:error, reason}`: A tuple containing `:error` and the error reason if the request fails or the HTTP status is not 200.

  ## Examples

      iex> Indexer.Api.execute_graphql_query(%{query: "query {...}", variables: %{}})
      {:ok, %{"data" => ...}}

      iex> Indexer.Api.execute_graphql_query(%{query: "query {...}", variables: %{invalid: true}})
      {:error, "HTTP status 400"}
  """
  def execute_graphql_query(%{query: query, variables: variables}) do
    headers = [
      {"x-api-user", @x_api_user},
      {"x-api-key", @x_api_key}
    ]

    body = %{
      query: query,
      variables: variables
    }

    case Req.post("https://api.indexer.xyz/graphql", json: body, headers: headers) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body["data"]}

      {:ok, %Req.Response{status: status}} ->
        Logger.error("Error executing GraphQL query: HTTP status #{status}")
        {:error, "HTTP status #{status}"}

      {:error, error} ->
        Logger.error("Error executing GraphQL query: #{error}")
        {:error, error}
    end
  end

  @doc """
  Builds a GraphQL query for retrieving trade-related information for a specific NFT collection and wallet.

  ## Parameters

  - `collection_id`: The UUID of the NFT collection.
  - `wallet`: The wallet address of the NFT owner.

  ## Returns

  A map with the `:query` key containing the GraphQL query string and the `:variables` key containing a map of the variables for the query. This map can be directly passed to `execute_graphql_query/1`.

  ## Examples

      iex> Indexer.Api.build_trade_query("uuid-of-the-collection", "wallet-address")
      %{
        query: "...",
        variables: %{
          "wallet" => "wallet-address",
          "collection_id" => "uuid-of-the-collection"
        }
      }

  """
  def build_trade_query(collection_id, wallet) do
    query = """
    query MyQuery($wallet: String!, $collection_id: uuid!) {
      aptos {
        nfts(where: {owner: {_eq: $wallet}, collection_id: {_eq: $collection_id}}) {
          owner
          id
          collection_id
          collection {
            title
            floor
          }
          token_id
          ranking
          listed
          listings(where: {listed: {_eq: true}}) {
                listed
                price
              }
          actions(order_by: {block_time: desc}) {
                price
                type
                block_time
                receiver
              }
        }
        collections(where: {id: {_eq: $collection_id}}) {
          id
          floor
          bids(where: {type: {_eq: "collection"}, status: {_eq: "active"}}, order_by: {price: desc}, limit: 2) {
            nonce
            price
            collection_id
            type
            status
            id
            bidder
          }
        }
        bids(where: {status: {_eq: "active"}, type: {_eq: "collection"}, bidder: {_eq: $wallet}, collection_id: {_eq: $collection_id}}) {
          collection_id
          price
          nonce
          id
          bidder
          status
          type
        }
        listings(where: {collection_id: {_eq: $collection_id}, listed: {_eq: true}}, order_by: {price: asc}, limit: 3) {
            listed
            price
            nft_id
            seller
          }
      }
    }
    """

    # Converting to string incase vars are passed in as charList
    wallet_str = to_string(wallet)
    collection_id_str = to_string(collection_id)

    variables = %{
      "wallet" => wallet_str,
      "collection_id" => collection_id_str
    }

    gql = %{query: query, variables: variables}
    gql
  end
end
