defmodule AuthPipe do
  alias GraphqlApi.Users
  alias GraphqlApi.AuthPipe.UserTokenBareExample
  alias GraphqlApi.AuthPipe.UserTokenNotify
  alias GraphqlApi.AuthPipe.UserTokenPersist
  alias GraphqlApi.AuthPipe.{UserProducer, UserToken}

  @doc "build the GenStage pipeline for creating/updating user auth tokens"
  def build() do
    # Producer is started with demand set to :accumulate 
    UserProducer.start_link(:ok, [])
    UserToken.start_link(:ok)
    # Used in development to notify that the events are flowing
    UserTokenBareExample.start_link(:ok)
    UserTokenNotify.start_link(:ok)
    UserTokenPersist.start_link(:ok)
    # start_link does not return until the init/1 function has returned
    # so now we can set the Producer demand to :forward to start moving
    # events through the pipeline and be sure that all Consumers will
    # receive all the Broadcast tokens
    GenStage.demand(UserProducer,:forward)
  end
  
  @doc "query the database and give a list of all user_id's to the pipeline"
  def update_all() do
    GenStage.cast(UserProducer,
      {:add, 
        Users.all 
        |> Enum.map(fn user -> user.id end)
      })
  end

  @doc "add a token for a newly created user"
  def create_token(user_id) do
    GenStage.cast(UserProducer,
      {:add, [user_id] }
    )
    
  end

end
