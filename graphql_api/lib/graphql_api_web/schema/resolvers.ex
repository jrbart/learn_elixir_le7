defmodule GraphqlApiWeb.Schema.Resolvers do
  @moduledoc false
  def find(%{id: id}, _) do
    id = String.to_integer(id)
    GraphqlApi.Users.get_by_id(id)
  end

  def filter(prefs, _) do
    GraphqlApi.Users.get_by_prefs(prefs)
  end

  def create(attrs, _) do
    GraphqlApi.Users.create_user(attrs)
  end

  def update_user(attrs, _) do
    {id, attrs} = Map.pop!(attrs, :id)
    id = String.to_integer(id)
    GraphqlApi.Users.update_user(id, attrs)
  end

  def update_prefs(attrs, _) do
    id =
      attrs
      |> Map.get(:user_id)
      |> String.to_integer()

    GraphqlApi.Users.update_prefs(id, attrs)
  end

  def get_hit_counter(hit, _) do
    res = hit.key
      |> Absinthe.Adapter.LanguageConventions.to_internal_name(nil)
      |> String.to_existing_atom()
      |> GraphqlApi.HitCounter.value()
    {:ok, res}
  end
end
