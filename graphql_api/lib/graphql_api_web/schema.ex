defmodule GraphqlApiWeb.Schema do
  @moduledoc false
  use Absinthe.Schema
  alias GraphqlApi.Users

  # Setup for Dataloader
  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Users, Users.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  def middleware(middleware, field, %Absinthe.Type.Object{identifier: identifier})
      when identifier in [:query, :subscription, :mutation] do
    SharedUtils.Logger.debug(__MODULE__, "Found KEY #{field.name}")

    case identifier do
      :mutation ->
        [GraphqlApiWeb.Middleware.Counter | middleware] ++
          [GraphqlApiWeb.Middleware.ChangesetErrors]

      _ ->
        [GraphqlApiWeb.Middleware.Counter | middleware]
    end
  end

  def middleware(middleware, _field, _object), do: middleware

  import_types(GraphqlApiWeb.Schema.Types)
  import_types(GraphqlApiWeb.Schema.Queries)
  import_types(GraphqlApiWeb.Schema.Mutations)
  import_types(GraphqlApiWeb.Schema.Subscriptions)

  query do
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:user_mutations)
  end

  subscription do
    import_fields(:user_subscriptions)
  end
end
