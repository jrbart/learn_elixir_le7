defmodule GraphqlApi.AuthPipe.UserTokenPersist do
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :nop, subscribe_to: [{GraphqlApi.AuthPipe.UserToken, max_demand: 50}]}
  end

  def handle_events(events, _from, state) do
    for {user, token} <- events do
      {:ok, _} = GraphqlApi.Users.update_token(user, token)
    end
    {:noreply, [], state}
  end
end
