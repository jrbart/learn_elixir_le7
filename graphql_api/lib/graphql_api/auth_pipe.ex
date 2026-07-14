defmodule GraphqlApi.AuthPipe do
  alias GraphqlApi.Accounts
  alias GraphqlApi.Repo
  alias GraphqlApi.Users
  alias GraphqlApi.AuthPipe.UserTokenNotify
  alias GraphqlApi.AuthPipe.UserTokenPersist
  alias GraphqlApi.AuthPipe.{UserProducer, UserToken}
  alias GraphqlApi.Accounts.Timestamps
  import Ecto.Query

  @doc "build the GenStage pipeline for updating user auth tokens"
  def run(users \\ nil) do

    # This should be done with a transaction...
    Repo.insert(%Accounts.Timestamps{timestamp:  DateTime.utc_now(:second)})
    
    users =
      case users do
        nil ->
          Users.all()
          |> Enum.map(fn user -> user.id end)

        _ ->
          users
      end

    # Producer is started with demand set to :accumulate 
    UserProducer.start_link(:ok, users)
    UserToken.start_link(:ok)
    UserTokenNotify.start_link(:ok)
    UserTokenPersist.start_link(:ok)
    # start_link does not return until the init/1 function has returned
    # so now we can set the Producer demand to :forward to start moving
    # events through the pipeline and be sure that all Consumers will
    # receive all the Broadcast tokens
    GenStage.demand(UserProducer, :forward)
  end

  def last_run do
    Repo.one(from(Timestamps, limit: 1, order_by: [desc: :timestamp]))
  end
end
