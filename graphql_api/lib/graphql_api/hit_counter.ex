defmodule GraphqlApi.HitCounter do
  use Agent

  def start_link(init \\ []) do
    Agent.start_link(fn -> init end, name: __MODULE__)
  end

  def value(key) do
    SharedUtils.Logger.info(__MODULE__, "GET #{key}")
    Agent.get(__MODULE__, &Keyword.get(&1, key, 0))
  end

  def increment(key) do
    SharedUtils.Logger.info(__MODULE__, "INC #{key} #{value(key)}")
    Agent.update(__MODULE__, &Keyword.update(&1, key, 1, fn v -> v + 1 end))
  end
end
