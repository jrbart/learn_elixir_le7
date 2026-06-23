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
    Process.flag(:trap_exit, true)
    # Artificially set min/max demand small so we can see interaction between
    # notify and persist consumers in our small data size...
    {:producer_consumer, state,
     subscribe_to: [{GraphqlApi.AuthPipe.UserProducer, min_demand: 1, max_demand: 4}],
     dispatcher: GenStage.BroadcastDispatcher}
  end

  @doc "Get a batch of user ids and generate tokens"
  def handle_events(events, _from, state) do
    res =
      for user <- events do
        SharedUtils.Logger.info(__MODULE__, "Generate user #{user} token")
        {user, gen_token()}
      end

    {:noreply, res, state}
  end
end
