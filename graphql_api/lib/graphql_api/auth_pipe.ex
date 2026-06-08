defmodule AuthPipe do
  alias GraphqlApi.AuthPipe.UserTokenBareExample
  alias GraphqlApi.AuthPipe.UserTokenNotify
  alias GraphqlApi.AuthPipe.UserTokenPersist
  alias GraphqlApi.AuthPipe.{UserProducer, UserToken}

  def run() do
    UserProducer.start_link(:ok, [])
    UserToken.start_link(:ok)
    UserTokenBareExample.start_link(:ok)
    UserTokenNotify.start_link(:ok)
    UserTokenPersist.start_link(:ok)
  end
end
