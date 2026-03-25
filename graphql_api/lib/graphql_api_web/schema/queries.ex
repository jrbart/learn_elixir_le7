defmodule GraphqlApiWeb.Schema.Queries do
  @moduledoc false
  use Absinthe.Schema.Notation

  alias GraphqlApiWeb.Schema.Resolvers

  object :user_queries do
    field :user, :user do
      arg :id, non_null(:id)
      resolve &Resolvers.find/2
    end

    field :users, list_of(:user) do
      arg :likes_emails, :boolean
      arg :likes_phone_calls, :boolean
      arg :likes_faxes, :boolean
      arg :before, :id
      arg :after, :id
      arg :first, :integer
      resolve &Resolvers.filter/2
    end

    field :resolver_hits, :integer do
      arg :key, :string
      resolve &Resolvers.get_hit_counter/2
    end
  end
end
