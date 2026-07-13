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
    children = [
      {GenerateTokens, 0}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
