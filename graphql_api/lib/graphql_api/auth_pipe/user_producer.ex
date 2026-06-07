defmodule GraphqlApi.AuthPipe.UserProducer do
  use GenStage

  alias GraphqlApi.Users

  def start_link(_, []) do
    GenStage.start_link(__MODULE__, {0, []}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    all_users =
      Users.all()
      |> Enum.map(fn user -> user.id end)

    # we keep the count in the state so we don't have to 
    # traverse the list on every iteration
    count = Enum.count(all_users)

    # Delay events until all consumers are ready to receive
    # https://gen-stage.hexdocs.pm/GenStage.BroadcastDispatcher.html#module-demand-while-setting-up
    {:producer, {count, all_users}, demand: :accumulate}
  end

  # TODO - define cast callback to start the pipe when ready using demand(:forward)

  @impl true
  def handle_demand(_demand, {0, []} = state) do
    SharedUtils.Logger.info(__MODULE__, "No more Users")
    # {:stop, :normal, nil}
    # See this for explanation of hibernate
    # https://elixir.hexdocs.pm/GenServer.html#c:handle_call/3
    {:noreply, [], state, :hibernate}
  end

  @impl true
  def handle_demand(demand, {count, users}) when demand > 0 do

    # IO.inspect(demand, label: "Producer DEMAND...")
    SharedUtils.Logger.info(__MODULE__, "Received DEMAND: #{demand}")

    cond do
      # We still have more to send after this batch
      demand < count ->
        {head, tail} = Enum.split(users, demand)
        {:noreply, head, {count - demand, tail}}

      # Send everything we have, then shutdown
      true ->
        SharedUtils.Logger.info(__MODULE__, "Shut down gracefully")
        GenStage.async_info(self(), :last_user)
        {:noreply, users, {0, []}, :hibernate}
    end
  end

  @impl true
  def handle_info(:last_user, state) do
    SharedUtils.Logger.info(__MODULE__, "Producer hibernating")
    # {:stop, :normal, state}
    # Sometimes if producer shutsdown, GenStage will shutdown consumers before entire buffer is consumed
    # Doing a hibernate here allows all consumers to finish processing all events before the GenStage pipeline
    # is terminated.
    # Possibly I will keep the GenStage hibernating until the next daily generation loop and just pass it 
    # a new list of users each time.  This would also keep it available to process new users when they
    # are created outside of the daily run...
    {:noreply, [], state, :hibernate}
  end
end
