defmodule GraphqlApi.Accounts.Timestamps do
  use Ecto.Schema
  @primary_key false

  schema "timestamps" do
    field :timestamp, :utc_datetime
  end
end
