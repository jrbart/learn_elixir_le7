defmodule GraphqlApi.Accounts.Timestamps do
  use Ecto.Schema
  # import Ecto.Changeset

  schema "timestamps" do
    field :timestamp, :utc_datetime
  end

  # @doc false
  # def changeset(user_token, attrs) do
  #   user_token
  #   |> cast(attrs, [:user_id, :token])
  #   |> validate_required([:user_id, :token])
  #   |> foreign_key_constraint(:user_id)
  # end
end
