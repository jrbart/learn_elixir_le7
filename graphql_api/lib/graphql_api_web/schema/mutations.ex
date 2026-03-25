defmodule GraphqlApiWeb.Schema.Mutations do
  @moduledoc false
  use Absinthe.Schema.Notation

  alias GraphqlApiWeb.Schema.Resolvers

  object :user_mutations do
    field :create_user, :user do
      arg :name, :string
      arg :email, :string
      arg :preferences, non_null(:user_preferences_create)
      resolve &Resolvers.create/2
    end

    field :update_user, :user do
      arg :id, non_null(:id)
      arg :name, :string
      arg :email, :string
      resolve &Resolvers.update_user/2
    end

    field :update_user_preferences, :user_preferences do
      arg :user_id, non_null(:id)
      arg :likes_emails, :boolean
      arg :likes_phone_calls, :boolean
      arg :likes_faxes, :boolean
      resolve &Resolvers.update_prefs/2
    end
  end
end
