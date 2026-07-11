defmodule GraphqlApi.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias GraphqlApi.Accounts.User

  schema "user_tokens" do
    # , redact: true
    field :token, :string

    belongs_to :user, User
  end

  @doc false
  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:user_id, :token])
    |> validate_required([:user_id, :token])
    |> foreign_key_constraint(:user_id)
  end
end
