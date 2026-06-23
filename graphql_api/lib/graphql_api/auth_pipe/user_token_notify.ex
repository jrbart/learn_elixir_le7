defmodule GraphqlApi.AuthPipe.UserTokenNotify do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :nop, subscribe_to: [{GraphqlApi.AuthPipe.UserToken, max_demand: 30}]}
  end

  def handle_events(events, _from, state) do
    SharedUtils.Logger.info(__MODULE__, "Received #{Enum.count(events)} events")

    for {user, token} <- events do
      SharedUtils.Logger.debug(__MODULE__, "Sending notify #{user} #{token}}")
      GraphqlApi.Users.notify(user, token)
    end

    {:noreply, [], state}
  end
end
