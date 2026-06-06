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

    {:producer, {count, all_users}, demand: :accumulate}
  end

  @impl true
  def handle_demand(_demand, {0, []} = state) do
    SharedUtils.Logger.info(__MODULE__, "No more Users")
    # {:stop, :normal, nil}
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
    {:noreply, [], state, :hibernate}
  end
end
