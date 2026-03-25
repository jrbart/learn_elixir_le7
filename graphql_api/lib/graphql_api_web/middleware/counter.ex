defmodule GraphqlApiWeb.Middleware.Counter do
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    resolution
    |> Absinthe.Resolution.path()
    |> List.first()
    |> GraphqlApi.HitCounter.increment()

    resolution
  end
end
