defmodule GraphqlApiWeb.Schema.Subscriptions do
  @moduledoc false
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    field :created_user, :user do
      config(fn _, _ -> {:ok, topic: "new_user"} end)
      trigger(:create_user, topic: fn _ -> "new_user" end)
    end

    field :updated_user_preferences, :user_preferences do
      arg :user_id, non_null(:id)
      config(fn %{user_id: id}, _ -> {:ok, topic: "user:#{id}"} end)
      trigger(:update_user_preferences, topic: fn %{user_id: id} -> "user:#{id}" end)
    end
  end
end
