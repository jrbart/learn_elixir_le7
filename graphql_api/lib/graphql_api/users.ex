defmodule GraphqlApi.Users do
  @moduledoc """
    This context module for Users contains functions for Absinthe resolvers.

    Every function should return a tagged tuple with either: 
      {:ok, data} or
      {:error, %{message: "message", details: %{key: value}}}
    suitable for Absinthe.
  """
  alias GraphqlApi.Accounts.User
  alias GraphqlApi.Accounts.UserToken
  alias GraphqlApi.Accounts.Preference
  alias GraphqlApi.Repo
  alias EctoShorts.Actions

  import SharedUtils.Error, only: [not_found: 2]

  @doc """
  Return list of all users.  Useful for experimenting in IEX repl
  """
  def all do
    Actions.all(User, preload: :preferences)
  end

  @doc """
  Return a tagged tuple wih {:ok, user} or {:error, message}
  """
  def get_by_id(id) do
    case Actions.get(User, id) do
      nil -> {:error, not_found("id: not found", %{details: %{id: id}})}
      user -> {:ok, user}
    end
  end

  @doc """
  Return a tagged tuple with {:ok, list_of_matching_users}.

  If no preferences are passed in, should return all users.
  If no preferences match, should return empty list.

  * Does not use relational filtering through EctoShorts *
  """
  def get_by_prefs(prefs) do
    users =
      for {key, value} <- prefs, reduce: User.join_preferences() do
        query -> Preference.compose(query, key, value)
      end
      |> Repo.all()

    {:ok, users}
  end

  @doc """
  Return a tagged tuple wih {:ok, token} or {:error, message}
  """
  def get_token_by_id(id) do
    case Actions.find(UserToken, user_id: id) do
      {:error, _} -> {:error, not_found("id: not found", %{details: %{id: id}})}
      token -> {:ok, token}
    end
  end

  @doc """
  Return a tuple with {:ok, created_user} or Ecto error tuple
  """
  def create_user(attrs) do
    user = User.changeset(%User{}, attrs)

    Repo.insert(user, preload: :preferences)
  end

  @doc """
  Return a tagged tuple with {:ok, update_attributes} or error
  tuple (possibly from Ecto)
  """
  def update_user(id, attrs) do
    with {:ok, user} <- get_by_id(id) do
      user
      |> User.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Return a tagged tuple with {:ok, updated_preferences} or {error
  tuple (possibly from Ecto)
  """
  def update_prefs(id, attrs) do
    with query <- Preference.compose(:user_id, id),
         %Preference{} = current_prefs <- Repo.one(query),
         changeset <- Preference.changeset(current_prefs, attrs) do
      Repo.update(changeset) 
    else
      _ -> {:error, not_found("id: not found", %{details: %{id: id}})}
    end
  end

  @doc "Update or insert"
  def update_token(user_id, token) do
    # According to Postgres documentation "on conflict" is more effecient than
    # trying an update an then doing insert if it fails, plus it is atomic
    with changeset <- UserToken.changeset(%UserToken{}, %{user_id: user_id, token: token}) do
      Repo.insert(
        changeset,
        on_conflict: {:replace, [:token]},
        conflict_target: :user_id
      )
    end
  end

  # TODO
  def notify(user, token) do
    Absinthe.Subscription.publish(GraphqlApiWeb.Endpoint, token, user_token: user)
  end

  # Query for Dataloaddataer
  @doc false
  def data(),
    do: Dataloader.Ecto.new(Repo, query: &query/2)

  @doc false
  def query(queryable, _params) do
    queryable
  end
end
