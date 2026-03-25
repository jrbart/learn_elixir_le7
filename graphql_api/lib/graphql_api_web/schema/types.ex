defmodule GraphqlApiWeb.Schema.Types do
  @moduledoc false
  use Absinthe.Schema.Notation
  alias GraphqlApi.Users
  import Absinthe.Resolution.Helpers

  object :user_preferences do
    field :likes_emails, :boolean
    field :likes_phone_calls, :boolean
    field :likes_faxes, :boolean
  end

  input_object :user_preferences_create do
    field :likes_emails, non_null(:boolean)
    field :likes_phone_calls, non_null(:boolean)
    field :likes_faxes, non_null(:boolean)
  end

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string

    field :preferences, :user_preferences do
      resolve dataloader(Users)
    end
  end
end
