defmodule GraphqlApi.AuthPipe.UserToken do
  use GenStage

  def gen_token() do
    :rand.bytes(12)
    |> Base.encode16()
  end

  def start_link(_init) do
    GenStage.start_link(__MODULE__, :user_token, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [GraphqlApi.AuthPipe.UserProducer], dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_events(events, _from, state) do
    SharedUtils.Logger.info(__MODULE__, "Received #{Enum.count(events)} events")
    res =
      for event <- events do
        {event, gen_token()}
      end

    {:noreply, res, state}
  end
end
