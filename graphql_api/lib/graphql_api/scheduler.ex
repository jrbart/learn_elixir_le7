defmodule GraphqlApi.Scheduler do
  alias GraphqlApi.Scheduler.GenerateTokens
  use Supervisor

  @moduledoc """
  Supervisor to manage schedulers
  """

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    SharedUtils.Logger.info(__MODULE__, "Supervisor starting...")

    children = [
      {GenerateTokens, 0},
      GraphqlApi.TokenCache.CacheTable
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
