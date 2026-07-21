defmodule GraphqlApi.Scheduler.GenerateTokens do
  alias GraphqlApi.Accounts.Timestamps
  use GenServer

  @moduledoc """
  A GenServer that runs once daily to re-generate all the user auth tokens
  """
  alias GraphqlApi.AuthPipe

  @seconds_in_day 24 * 60 * 60

  # Startup (Initialization)

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(init) do
    SharedUtils.Logger.info(__MODULE__, "Starting...")
    initial_state = init

    # Check on startup if it has been more that 24 hours since
    # new tokens were generated
    last_timestamp = AuthPipe.last_run()
    this_timesig = DateTime.now!("Etc/UTC")
    maybe_run_pipeline(last_timestamp, this_timesig)

    {:ok, initial_state, {:continue, :schedule_next}}
  end

  # Callbacks

  @impl true
  def handle_info(:generate_new_tokens, state) do
    SharedUtils.Logger.debug(__MODULE__, "Generating new tokens...")

    AuthPipe.run()
    {:noreply, state, {:continue, :schedule_next}}
  end

  @impl true
  def handle_continue(:schedule_next, state) do
    SharedUtils.Logger.debug(__MODULE__, "Scheduling next run...")
    seconds_to_wait = next_run()

    Process.send_after(self(), :generate_new_tokens, seconds_to_wait * 1000)
    {:noreply, state}
  end

  # Helpers

  def next_run(
        current_time \\ Time.utc_now(),
        daily_time \\ Application.get_env(:graphql_api, __MODULE__)[:daily_run]
      ) do
    SharedUtils.Logger.info(__MODULE__, "Daily run time: #{daily_time}")

    # Number of seconds until tomorrow's run time
    # We recalulate this each time because tiny delays will eventually add
    # up and cause drift, running later and later...
    {today_seconds, _} = Time.to_seconds_after_midnight(current_time)
    {target_seconds, _} = Time.to_seconds_after_midnight(daily_time)
    seconds_to_wait = rem(@seconds_in_day - today_seconds + target_seconds, @seconds_in_day)
    SharedUtils.Logger.info(__MODULE__, "Seconds to wait: #{seconds_to_wait}")
    # if current_time is so close that it is zero, then return a full day
    if seconds_to_wait == 0, do: @seconds_in_day, else: seconds_to_wait
  end

  # if there is no timestamp from previous runs, then generate new tokens
  def maybe_run_pipeline(nil, _) do
    Process.send(self(), :generate_new_tokens, [])
  end

  # if the timestamp was 24 or more hours ago, then generate new tokens
  def maybe_run_pipeline(%Timestamps{} = prev, %DateTime{} = current) do
    if DateTime.diff(prev.timestamp, current, :hour) >= 24 do
      Process.send(self(), :generate_new_tokens, [])
    end
  end
end
