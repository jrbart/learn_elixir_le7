defmodule GraphqlApi.Scheduler.GenerateTokens do
  use GenServer

  @moduledoc """
  A GenServer that runs once daily to re-generate all the user auth tokens
  """
  alias GraphqlApi.Users
  alias GraphqlApi.AuthPipe

  # Client (API)

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  # def send(pid, arg) do
  #   GenServer.cast(pid, {:async_call, arg})
  # end
  #
  # def rec(pid) do
  #   GenServer.call(pid, :sync_call)
  # end
  #
  # Server (callbacks)

  # TODO
  # Right now we automatically re-generate all tokens on startup
  # We need to add some logic to check a timestamp to see if it has 
  # been less than 24 hours, then skip this 
  # And also set a timer to wake up at appropriate time 
  # to run each 24 hours

  @impl true
  def init(init) do
    initial_state = init

    users =
      Users.all()
      |> Enum.map(fn user -> user.id end)

    AuthPipe.run(users)
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:sync_call, _from, state) do
    [res | new_state] = state
    {:reply, res, new_state}
  end

  @impl true
  def handle_cast({:async_call, arg}, state) do
    new_state = [arg | state]
    {:noreply, new_state}
  end
end
