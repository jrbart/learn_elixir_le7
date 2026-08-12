defmodule GraphqlApi.HitCounter do
  use Agent

  @moduledoc """
  An Agent that stores and increments a key that represents a graphql endpoint
  """

  def start_link(init \\ []) do
    Agent.start_link(fn -> init end, name: __MODULE__)
  end

  @doc """
  Get the value of the key
  """
  def value(key) do
    SharedUtils.Logger.debug(__MODULE__, "GET #{key}")
    Agent.get(__MODULE__, &Keyword.get(&1, key, 0))
  end

  @doc """
  This will increment the key using a task so it is non-blocking
  """
  def increment(key) do
    SharedUtils.Logger.debug(__MODULE__, "INC #{key} #{value(key)}")

    Task.start(fn ->
      Agent.update(__MODULE__, &Keyword.update(&1, key, 1, fn v -> v + 1 end))
    end)

    :ok
  end
end
