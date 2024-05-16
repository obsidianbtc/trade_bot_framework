defmodule StrategyCollectionFloorPipelineTest do
  use ExUnit.Case

  alias Strategy.CollectionFloor.Pipeline, as: Pipeline

  describe "decide_action/1" do
    test ":bids removes bid when not profitable" do
      args = bids_args(profitable: false)
      assert Pipeline.decide_action({:bids, args}) == {:remove_bid, args.my_bids |> hd}
    end

    test ":bids removes bid when profitable but not highest bidder" do
      args = bids_args(profitable: true, highest_bid: false)
      assert Pipeline.decide_action({:bids, args}) == {:remove_bid, args.my_bids |> hd}
    end

    test ":bids takes no action when profitable, highest bidder, but cannot lower bid" do
      args = bids_args(profitable: true, highest_bid: true, lower_bid: false)
      assert Pipeline.decide_action({:bids, args}) == {:no_action}
    end

    test ":bids removes bid when profitable, highest bidder, and can lower bid" do
      args = bids_args(profitable: true, highest_bid: true, lower_bid: true)
      assert Pipeline.decide_action({:bids, args}) == {:remove_bid, args.my_bids |> hd}
    end

    test ":empty bid floor spread is profitable" do
      args = bids_args(profitable: true)
      [bid1, _bid2] = args.collection_bids
      assert Pipeline.decide_action({:empty, args}) == {:place_bid, bid1["price"] + 1}
    end

    test ":empty bid floor spread is NOT profitable" do
      args = bids_args(profitable: false)
      [bid1, _bid2] = args.collection_bids
      assert Pipeline.decide_action({:empty, args}) == {:no_action}
    end

    test ":nfts Nft NOT listed, Floor Not Profitable" do
      args = nft_args(nft_listed: false, floor_profitable: false)
      assert Pipeline.decide_action({:nfts, args}) == {:no_action}
    end

    test ":nfts Nft NOT listed, Below Floor IS Profitable" do
      args = nft_args(nft_listed: false, floor_profitable: true)
      [my_nft] = args.my_nfts

      assert Pipeline.decide_action({:nfts, args}) ==
               {:list_nft, {my_nft, args.collection_info.floor_listing["price"] - 1}}
    end

    test ":nfts Nft listed, Below Floor NOT Profitable" do
      args = nft_args(nft_listed: true, floor_profitable: false)

      assert Pipeline.decide_action({:nfts, args}) ==
               {:no_action}
    end

    test ":nfts Nft listed, floor profitable, not floor nft" do
      args = nft_args(nft_listed: true, floor_profitable: true, floor_nft: false)
      [my_nft] = args.my_nfts

      assert Pipeline.decide_action({:nfts, args}) ==
               {:list_nft, {my_nft, args.collection_info.floor_listing["price"] - 1}}
    end

    test ":nfts Nft listed, floor profitable, floor nft, can raise price" do
      args = nft_args(nft_listed: true, floor_profitable: true, floor_nft: true, raise_nft: true)
      [my_nft] = args.my_nfts

      assert Pipeline.decide_action({:nfts, args}) ==
               {:list_nft, {my_nft, Enum.at(args.collection_listings, 1)["price"] - 1}}
    end
  end

  defp bids_args(opts) do
    %{
      chain: "aptos",
      wallet: "0xd",
      collection_id: "22cd6470-b924-46a9-985f-4e1f91b85071",
      my_bids: [
        %{
          "bidder" => "0xd",
          "price" => 690_000_001
        }
      ],
      collection_bids: [
        %{
          "price" => 690_000_001
        },
        %{
          "price" => if(opts[:lower_bid], do: 689_999_999, else: 690_000_000)
        }
      ],
      collection_info: %{
        highest_bid: %{
          "bidder" =>
            if(opts[:highest_bid],
              do: "0xd",
              else: "other_bidder"
            ),
          "price" => 690_000_001
        },
        floor_listing: %{
          "price" => if(opts[:profitable], do: 930_000_000, else: 680_000_000)
        }
      }
    }
  end

  defp empty_args(opts) do
    %{
      chain: "aptos",
      wallet: "0xd",
      collection_id: "22cd6470-b924-46a9-985f-4e1f91b85071",
      my_bids: [],
      collection_bids: [
        %{
          "price" => 690_000_001
        },
        %{
          "price" => if(opts[:lower_bid], do: 689_999_999, else: 690_000_000)
        }
      ],
      collection_info: %{
        highest_bid: %{
          "bidder" =>
            if(opts[:highest_bid],
              do: "0xd",
              else: "other_bidder"
            ),
          "price" => 690_000_001
        },
        floor_listing: %{
          "price" => if(opts[:profitable], do: 930_000_000, else: 680_000_000)
        }
      }
    }
  end

  defp nft_args(opts) do
    %{
      chain: "aptos",
      wallet: "0xd",
      collection_id: "22cd6470-b924-46a9-985f-4e1f91b85071",
      my_nfts: [
        %{
          "listed" => if(opts[:nft_listed], do: true, else: false),
          "nft_id" => "eaf9bb64-c981-4e3c-b5f8-7cdd72c53cbf",
          "price" => 899_999_999,
          "seller" => "0xd",
          "actions" => [
            %{
              "id" => "428c287c-5841-42b9-a222-bd14be2a463c",
              "type" => "accept-collection-bid",
              "price" => 700_000_001,
              "sender" => "0x",
              "receiver" => "0x",
              "tx_id" => "0x699bdb2cae73a9d659bc4652c8d2eebfac42bdf4edba325b45f90e0d35972dd1",
              "block_time" => "2024-03-23T13:57:18.082",
              "market_name" => "tradeport"
            },
            %{
              "id" => "d6b45649-20c4-4299-a85f-bbd94af27436",
              "type" => "unlist",
              "price" => nil,
              "sender" => "0x",
              "receiver" => nil,
              "tx_id" => "0x",
              "block_time" => "2024-03-23T13:57:18.082",
              "market_name" => "tradeport"
            },
            %{
              "id" => "d3a9b5b5-6cee-4daa-a011-e7da2b9fb15a",
              "type" => "list",
              "price" => 880_000_000,
              "sender" => "0x",
              "receiver" => nil,
              "tx_id" => "0x",
              "block_time" => "2024-03-23T13:55:39.742",
              "market_name" => "tradeport"
            },
            %{
              "id" => "63fa5e7b-7c9f-419b-b41e-f6fab023c2d5",
              "type" => "unlist",
              "price" => nil,
              "sender" => "0x5",
              "receiver" => nil,
              "tx_id" => "0xf",
              "block_time" => "2024-03-16T19:31:34.419",
              "market_name" => "wapal"
            },
            %{
              "id" => "c08b10e8-f237-43d4-b10d-5e9031e53995",
              "type" => "list",
              "price" => 2_200_000_000,
              "sender" => "0x5",
              "receiver" => nil,
              "tx_id" => "0xb",
              "block_time" => "2024-03-16T19:30:33.528",
              "market_name" => "wapal"
            },
            %{
              "id" => "b789987d-043b-4f7c-8d46-98aae5c94d24",
              "type" => "transfer",
              "price" => nil,
              "sender" => "0xa",
              "receiver" => "0x5",
              "tx_id" => "0xc7dfbfaba8f48f0e71069455d0b69d910fed537495234389faefd95b9aeef462",
              "block_time" => "2024-03-14T18:09:36.835",
              "market_name" => nil
            },
            %{
              "id" => "7c6910c4-302c-4e99-aaf1-22851a87c280",
              "type" => "transfer",
              "price" => nil,
              "sender" => nil,
              "receiver" => "0xa",
              "tx_id" => "0xa",
              "block_time" => "2024-03-14T18:05:02.167",
              "market_name" => nil
            },
            %{
              "id" => "a80f63c2-c721-486a-9ffb-b518b31a4447",
              "type" => "buy",
              "price" => 340_000_000,
              "sender" => "0x8",
              "receiver" => "0xa",
              "tx_id" => "0xa812bbad490833cbb9a749158a10c3a2300a0641aafb28a496d3f2bfa932e63c",
              "block_time" => "2024-03-14T18:05:02.167",
              "market_name" => "tradeport"
            },
            %{
              "id" => "4b51792c-6557-4f49-bc6b-a1557530acda",
              "type" => "list",
              "price" => 340_000_000,
              "sender" => "0x8",
              "receiver" => nil,
              "tx_id" => "0xb",
              "block_time" => "2024-03-14T18:01:13.318",
              "market_name" => "tradeport"
            },
            %{
              "id" => "a484abfc-653b-4757-8d31-cb418cd113ca",
              "type" => "list",
              "price" => 340_000_000,
              "sender" => "0x8",
              "receiver" => nil,
              "tx_id" => "0x",
              "block_time" => "2024-03-14T18:01:01.297",
              "market_name" => "tradeport"
            },
            %{
              "id" => "630f79e2-30bd-4362-9a7f-7cd25fe5e981",
              "type" => "list",
              "price" => 344_000_000,
              "sender" => "0x8",
              "receiver" => nil,
              "tx_id" => "0x68",
              "block_time" => "2024-03-14T17:58:17.968",
              "market_name" => "tradeport"
            },
            %{
              "id" => "308480b0-2d1d-4fab-b0e4-6ae21dfd6fc1",
              "type" => "list",
              "price" => 350_000_000,
              "sender" => "0x8",
              "receiver" => nil,
              "tx_id" => "0xd",
              "block_time" => "2024-03-14T17:54:53.021",
              "market_name" => "tradeport"
            }
          ]
        }
      ],
      my_bids: [],
      collection_bids: [
        %{
          "bidder" => "0xd",
          "collection_id" => "22cd6470-b924-46a9-985f-4e1f91b85071",
          "id" => "36009a15-0206-4795-9a07-9e49fc92b57d",
          "nonce" => "0xd",
          "price" => 690_000_001,
          "status" => "active",
          "type" => "collection"
        },
        %{
          "bidder" => "0x3",
          "collection_id" => "22cd6470-b924-46a9-985f-4e1f91b85071",
          "id" => "7f88a3d4-ab2f-4ecd-9aef-d1b7bdbaba17",
          "nonce" => "0xe",
          "price" => 690_000_000,
          "status" => "active",
          "type" => "collection"
        }
      ],
      collection_listings: [
        %{
          "listed" => true,
          "nft_id" => "eaf9bb64-c981-4e3c-b5f8-7cdd72c53cbf",
          "price" => if(opts[:floor_profitable], do: 899_999_999, else: 700_000_001),
          "seller" => "0xd"
        },
        %{
          "listed" => true,
          "nft_id" => "1e41904c-8482-48d6-a07c-42121a643193",
          "price" => if(opts[:raise_nft], do: 900_000_001, else: 900_000_000),
          "seller" => "0x5"
        },
        %{
          "listed" => true,
          "nft_id" => "75b24c2e-123c-4c2c-8952-a132c3df714b",
          "price" => 900_000_000,
          "seller" => "0x1"
        }
      ],
      collection_info: %{
        highest_bid: %{
          "bidder" => "0xd",
          "collection_id" => "22cd6470-b924-46a9-985f-4e1f91b85071",
          "id" => "36009a15-0206-4795-9a07-9e49fc92b57d",
          "nonce" => "0xd",
          "price" => 690_000_001,
          "status" => "active",
          "type" => "collection"
        },
        floor_listing: %{
          "listed" => true,
          "nft_id" => "eaf9bb64-c981-4e3c-b5f8-7cdd72c53cbf",
          "price" => if(opts[:floor_profitable], do: 899_999_999, else: 700_000_001),
          "seller" =>
            if(opts[:floor_nft],
              do: "0xd",
              else: "0xa"
            )
        }
      }
    }
  end
end
