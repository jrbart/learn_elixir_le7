defmodule GraphqlApi.AuthPipe.UserProducer do
  use GenStage

  def start_link(_, []) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(init_users) do

    # we keep the count in the state so we don't have to 
    # traverse the list on every iteration
    # if demand comes before there is any supply, keep it 
    # in count as a negative number so events can be sent 
    # immediately when they are supplied
    count = Enum.count(init_users)

    # Delay events until all consumers are ready to receive
    # https://gen-stage.hexdocs.pm/GenStage.BroadcastDispatcher.html#module-demand-while-setting-up
    {:producer, {count, init_users}, demand: :accumulate}
  end

  @impl true
  def handle_cast({:add, users}, {count, list} = state) do
    SharedUtils.Logger.info(__MODULE__, "ADD: #{inspect(users)}")
    SharedUtils.Logger.debug(__MODULE__, "ADD: #{inspect(state)}")
    # Do I need to do a binary copy here so that memory can be garbage collected
    # Or should I just go ahead and let the GenStage die and recycle since it will
    # be waiting around for 24 hours?
    new_state = {count + Enum.count(users), list ++ users}
    # Send up to remaining demain, put the rest in state for next batch
    #TODO
    {:noreply, users, new_state}
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
      demand <= count ->
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
    SharedUtils.Logger.info(__MODULE__, "Producer hibernating")
    {:stop, :normal, state}
    # Sometimes if producer shutsdown, GenStage will shutdown consumers before entire buffer is consumed
    # Doing a hibernate here allows all consumers to finish processing all events before the GenStage pipeline
    # is terminated, but keeps the GenStage in hibernation.  How do I know when last token is saved and last
    # notification is sent so I can finally actually terminate the GenStage?
    # Possibly I will keep the GenStage hibernating until the next daily generation loop and just pass it 
    # a new list of users each time.  This would also keep it available to process new users when they
    # are created outside of the daily run...
    # {:noreply, [], state, :hibernate}
  end
end
