defmodule GraphqlApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias GraphqlApi.Accounts.Preference
  alias GraphqlApi.Accounts.UserToken
  alias __MODULE__

  schema "users" do
    field :name, :string
    field :email, :string

    has_one :preferences, Preference, on_replace: :update
    has_one :token, UserToken
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> cast_assoc(:preferences, on_replace: :update)
    |> unique_constraint(:email, message: "invalid email address")
  end

  # Relational queries
  def join_preferences(query \\ User) do
    join(query, :inner, [u], p in assoc(u, :preferences), as: :preferences)
  end
end
