defmodule GraphqlApi.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias GraphqlApi.Accounts.User
  alias GraphqlApi.Repo

  schema "user_tokens" do
    field :token, :string, redact: true

    belongs_to :user, User
  end

  @doc "Update or insert"
  def insert(changeset) do
    Repo.insert(
      changeset,
      on_conflict: {:replace, [:token]},
      conflict_target: :user_id
    )
  end

  @doc false
  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:user_id, :token])
    |> validate_required([:user_id, :token])
  end
end
