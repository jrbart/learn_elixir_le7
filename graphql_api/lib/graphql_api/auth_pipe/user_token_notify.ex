defmodule GraphqlApi.AuthPipe.UserTokenNotify do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :nop, subscribe_to: [{GraphqlApi.AuthPipe.UserToken, max_demand: 30}]}
  end

  def handle_events(events, _from, state) do
    IO.inspect(events, label: "Broadcast EVENTS")
    {:noreply, [], state}
  end
end
