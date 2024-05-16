defmodule Utils.ProfitCalc do
  require Logger
  # Define a struct to hold the royalty information for better organization
  defstruct chain: nil, collection_id: nil, royalty: nil

  # Initialize a map to hold the royalty rates for known collections
  @royalties %{
    # Ice Blue
    {:aptos, "22cd6470-b924-46a9-985f-4e1f91b85071"} => 0.08,
    # Spooks
    {:aptos, "1207a954-b35d-4b20-9f49-1b4a5a53c907"} => 0.06,
    # Aptos Monkeys
    {:aptos, "c4b6e0dd-b4b7-4dba-a6ae-3cca29ccab71"} => 0.05,
    # Bruh Bears
    {:aptos, "2567f5c5-9c96-462c-a73c-51fe52709a68"} => 0.055,
    # Zaptos
    {:aptos, "e95fe36f-3803-4307-b685-1e745f708d6f"} => 0.08,
    # Creatus
    {:aptos, "47212524-4e48-422b-a146-451895204c88"} => 0.05,
    # Happy Mover
    {:aptos, "7192099-f23a-447d-af3c-1c1a7221df13"} => 0.001
  }

  # Define default royalties for each chain in the absence of a specific collection
  @default_royalties %{
    aptos: 0.10,
    sui: 0.10
  }

  # Define commission rates for each chain
  @commissions %{
    aptos: 0.015,
    sui: 0.025
  }

  def check_profit(chain_str, collection_id, list_price, acquisition_cost) do
    chain = String.to_atom(chain_str)
    commission = get_commission(chain)
    royalty = get_royalty(chain, collection_id)

    receive = list_price * (1 - commission - royalty)

    # Logger.info("I will make #{(receive - acquisition_cost) / 100_000_000} profit from this sale")

    receive > acquisition_cost
  end

  defp get_royalty(chain, collection_id) do
    # Attempt to fetch the specific collection's royalty from the map, fallback to default if not found
    Map.get(@royalties, {chain, collection_id}, @default_royalties[chain])
  end

  defp get_commission(chain) do
    # Fetch the commission rate based on the blockchain used
    Map.get(@commissions, chain)
  end
end
