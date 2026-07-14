defmodule GraphqlApi.Scheduler.GenerateTokens do
  use GenServer

  @moduledoc """
  A GenServer that runs once daily to re-generate all the user auth tokens
  """
  alias GraphqlApi.AuthPipe

  @seconds_in_day 24*60*60

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(init) do
    initial_state = init

    # Check on startup if it has been more that 24 hours since
    # new tokens were generated
    last_run = AuthPipe.last_run() 
    last_time =
      if is_nil(last_run) do 
        DateTime.now!("Etc/UTC")
      else 
        last_run.timestamp
      end
    if DateTime.diff(DateTime.now!("Etc/UTC"), last_time, :hour) >= 24 do
      Process.send(self(), :generate_new_tokens, [])
    end

    {:ok, initial_state, {:continue, :schedule_next}}
  end

  @impl true
  def handle_info(:generate_new_tokens, state) do

    AuthPipe.run()
    {:noreply, state, {:continue, :schedule_next}}
  end

  @impl true
  def handle_continue(:schedule_next, state) do
    seconds_to_wait = next_run()

    Process.send_after(self(), :generate_new_tokens, seconds_to_wait * 1000)
    {:noreply, state}
  end

  # Helpers

  def next_run do
    config = Application.get_env(:graphql_api, __MODULE__)
    next_run_time = config[:daily_run]
    SharedUtils.Logger.info(__MODULE__, "Daily run time: #{next_run_time}")

    # Number of seconds until tomorrow's run time
    # We recalulate this each time because tiny delays will eventually add
    # up and cause drift, running later and later...
    current_time = Time.utc_now()
    today_seconds = Time.to_seconds_after_midnight(current_time) |> elem(0)
    target_seconds = Time.to_seconds_after_midnight(next_run_time) |> elem(0)
    seconds_to_wait = rem(@seconds_in_day - today_seconds + target_seconds, 86_400)
    SharedUtils.Logger.info(__MODULE__, "Seconds to wait: #{seconds_to_wait}")
    seconds_to_wait
   end 
end
