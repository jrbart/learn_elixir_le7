defmodule GraphqlApi.HitCounter do
  require Logger
  use Agent

  def start_link(init \\ %{}) do
    Agent.start_link(fn -> init end, name: __MODULE__)
  end

  def value(key) do
    Agent.get(__MODULE__, &Map.get(&1, key, 0))
  end

  def increment(key) do
    Logger.info("INC #{key} #{value(key)}")
    Agent.update(__MODULE__, &Map.update(&1, key, 1, fn v -> v + 1 end))
  end
end
