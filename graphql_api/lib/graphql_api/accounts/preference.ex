defmodule GraphqlApi.Accounts.Preference do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias GraphqlApi.Accounts.User
  alias GraphqlApi.Accounts.Preference
  alias EctoShorts.CommonFilters, as: CF

  @primary_key false
  schema "preferences" do
    field :likes_emails, :boolean
    field :likes_phone_calls, :boolean
    field :likes_faxes, :boolean

    belongs_to :user, User, primary_key: true
  end

  @doc false
  def changeset(preference, attrs) do
    preference
    |> cast(attrs, [:likes_emails, :likes_phone_calls, :likes_faxes, :user_id])
    |> validate_required([:likes_emails, :likes_phone_calls, :likes_faxes])
  end

  # Reusable queries from https://learn-elixir.dev/blogs/creating-reusable-ecto-code
  def from(query \\ Preference), do: from(query, as: :preferences)

  # BAD NAME -- maybe "compose"?
  def get_by(query \\ from(), key, value)

  # order results w EctoShorts
  def get_by(query, :after, value), do: CF.convert_params_to_filter(query, %{after: value})
  def get_by(query, :before, value), do: CF.convert_params_to_filter(query, %{before: value})
  def get_by(query, :first, value), do: CF.convert_params_to_filter(query, %{first: value})

  # filter results by field
  def get_by(query, key, value) do
    where(query, [preferences: p], field(p, ^key) == ^value)
  end
end
