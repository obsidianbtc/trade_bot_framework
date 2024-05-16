defmodule Strategy.TestData.Data do
  def test_bids() do
    {
      :bids,
      %{
        chain: "aptos",
        wallet: "0x1",
        collection_id: "22cd6470-b924-46a9-985f-4e1f91b85071",
        my_nfts: [],
        my_bids: [
          %{
            "bidder" => "0x1",
            "collection_id" => "22cd6470-b924-46a9-985f-4e1f91b85071",
            "id" => "36009a15-0206-4795-9a07-9e49fc92b57d",
            "nonce" => "0x2",
            "price" => 690_000_001,
            "status" => "active",
            "type" => "collection"
          }
        ],
        collection_bids: [
          %{
            "bidder" => "0x1",
            "collection_id" => "22cd6470-b924-46a9-985f-4e1f91b85071",
            "id" => "36009a15-0206-4795-9a07-9e49fc92b57d",
            "nonce" => "0x2",
            "price" => 690_000_001,
            "status" => "active",
            "type" => "collection"
          },
          %{
            "bidder" => "0x3",
            "collection_id" => "22cd6470-b924-46a9-985f-4e1f91b85071",
            "id" => "7f88a3d4-ab2f-4ecd-9aef-d1b7bdbaba17",
            "nonce" => "0xea",
            "price" => 690_000_000,
            "status" => "active",
            "type" => "collection"
          }
        ],
        collection_listings: [
          %{
            "listed" => true,
            "nft_id" => "eaf9bb64-c981-4e3c-b5f8-7cdd72c53cbf",
            "price" => 799_000_000,
            "seller" => "0xa"
          },
          %{
            "listed" => true,
            "nft_id" => "1e41904c-8482-48d6-a07c-42121a643193",
            "price" => 800_000_000,
            "seller" => "0x5"
          },
          %{
            "listed" => true,
            "nft_id" => "75b24c2e-123c-4c2c-8952-a132c3df714b",
            "price" => 800_000_000,
            "seller" => "c0"
          }
        ],
        collection_info: %{
          highest_bid: %{
            "bidder" => "0x1",
            "collection_id" => "22cd6470-b924-46a9-985f-4e1f91b85071",
            "id" => "36009a15-0206-4795-9a07-9e49fc92b57d",
            "nonce" => "0x2",
            "price" => 690_000_001,
            "status" => "active",
            "type" => "collection"
          },
          floor_listing: %{
            "listed" => true,
            "nft_id" => "eaf9bb64-c981-4e3c-b5f8-7cdd72c53cbf",
            "price" => 799_000_000,
            "seller" => "0x"
          }
        }
      }
    }
  end
end
