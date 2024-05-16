defmodule Strategy.CollectionFloor.Worker do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:name])
  end

  @impl true
  def init(%{chain: _chain, collection_id: _collection_id, wallet: wallet} = state) do
    Logger.info("Starting pipeline for wallet: #{wallet}")
    {:ok, state, {:continue, :start_pipeline}}
  end

  @impl true
  def handle_continue(:start_pipeline, state) do
    schedule_work(2000)
    {:noreply, state}
  end

  defp schedule_work(delay) do
    Process.send_after(self(), :run_pipeline, delay)
  end

  @impl true
  def handle_info(:run_pipeline, state) do
    state
    |> Strategy.CollectionFloor.Pipeline.pipeline()
    |> handle_result()

    # schedule next run
    # schedule_work(:rand.uniform(90_000 - 1000) + 1000)
    schedule_work(10000)
    {:noreply, state}
  end

  defp handle_result(_result) do
    # Logger.info("Pipeline result: #{inspect(result)}")
    # handle the result of the pipeline function here
    {:ok}
  end
end
