defmodule GraphqlApi.GenerateTokensTest do
  alias GraphqlApi.Scheduler.GenerateTokens
  alias GraphqlApi.Accounts.Timestamps
  use ExUnit.Case

  describe "&GenerateTokens.maybe_run_pipeline/0" do
    test "generates tokens if no Timestamps" do
      GenerateTokens.maybe_run_pipeline(nil, true)
      assert_receive(:generate_new_tokens)
    end

    test "generates tokens if is has been >= 24 hours" do
      {:ok, dt} = DateTime.now("Etc/UTC")
      ts = %Timestamps{timestamp: dt}

      GenerateTokens.maybe_run_pipeline(ts, DateTime.shift(dt, hour: -24))

      assert_receive(:generate_new_tokens)
    end

    test "does not generate tokens if < 24 hours" do
      {:ok, dt} = DateTime.now("Etc/UTC")
      ts = %Timestamps{timestamp: dt}

      # this is one second before -24 hours...
      GenerateTokens.maybe_run_pipeline(ts, DateTime.shift(dt, hour: -24, second: 1))

      refute_receive(:generate_new_tokens)
    end
  end

  describe "&GenerateTokens.next_run/1" do
    test "calculates number of seconds if we drifted 1 minute" do
      fake_time = ~T"03:01:00.000"
      next_time = ~T"03:00:00.000"

      assert GenerateTokens.next_run(fake_time, next_time) == 24 * 60 * 60 - 60
    end

    test "calculates number of seconds" do
      fake_time = ~T"03:00:00.001"
      next_time = ~T"03:00:00.000"

      assert GenerateTokens.next_run(fake_time, next_time) == 24 * 60 * 60
    end
  end
end
