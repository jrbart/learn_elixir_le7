defmodule GraphqlApi.AuthPipe.UserProducer do
  use GenStage

  def start_link(_, users) do
    GenStage.start_link(__MODULE__, users, name: __MODULE__)
  end

  @impl true
  def init(init_users) do
    # we keep the count in the state so we don't have to 
    # traverse the list on every iteration
    count = Enum.count(init_users)

    # Delay events until all consumers are ready to receive
    # https://gen-stage.hexdocs.pm/GenStage.BroadcastDispatcher.html#module-demand-while-setting-up
    {:producer, {count, init_users}, demand: :accumulate}
  end

  @impl true
  def handle_demand(_demand, {0, []} = state) do
    SharedUtils.Logger.info(__MODULE__, "Waiting for batch")
    # See this for explanation of hibernate
    # https://elixir.hexdocs.pm/GenServer.html#c:handle_call/3
    {:noreply, [], state, :hibernate}
  end

  @impl true
  def handle_demand(demand, {count, users}) when demand > 0 do
    SharedUtils.Logger.info(__MODULE__, "Received DEMAND: #{demand}")

    cond do
      # We still have more to send after this batch
      demand < count ->
        {head, tail} = Enum.split(users, demand)
        {:noreply, head, {count - demand, tail}}

      # Send everything we have, track remaining demand
      true ->
        # SharedUtils.Logger.info(__MODULE__, "Wait for more, hibernate")
        GenStage.async_info(self(), :last_user)
        {:noreply, users, {count - demand, []}, :hibernate}
    end
  end

  @impl true
  def handle_info(:last_user, state) do
    SharedUtils.Logger.info(__MODULE__, "Producer terminating")
    {:stop, :normal, state}
  end
end
