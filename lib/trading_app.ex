defmodule TradingApp do
  use Application

  def start(_type, _args) do
    children = [
      Supervisor.child_spec(
        {Strategy.CollectionFloor.Worker,
         %{
           chain: "aptos",
           collection_id: "insert_collection_id_from_indexer_api",
           wallet: "insert_wallet",
           name: :change_name_here
         }},
        # Unique id for the worker
        id: :change_name_worker
      )
      # Other supervised processes can be added here
    ]

    opts = [strategy: :one_for_one, name: TradingApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
