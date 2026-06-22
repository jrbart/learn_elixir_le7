defmodule GraphqlApi.AuthPipe.UserTokenBareExample do
  @moduledoc """
    This module is used for proof of concept: 
      that Broadcast works,
      that all events get consumed,
      that buffered events don't get dropped when 
        Producer stops

  """
  use GenStage

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :nop, subscribe_to: [{GraphqlApi.AuthPipe.UserToken, max_demand: 2}]}
  end

  def handle_events(events, _from, state) do
    SharedUtils.Logger.info(__MODULE__, "CONSUME #{Enum.count(events)} events")
    for {user, token} <- events do
      SharedUtils.Logger.debug(__MODULE__, "CONSUMING #{user} #{token}}")
      # Process.sleep(100)
      IO.inspect(user, label: :User)
    end
    {:noreply, [], state}
  end
end
