defmodule AuthPipe do
  alias GraphqlApi.AuthPipe.UserTokenBroadcast
  alias GraphqlApi.AuthPipe.UserTokenPermanent
  alias GraphqlApi.AuthPipe.{UserProducer, UserToken, UserSpew}

  def run() do
    UserProducer.start_link(:ok, [])
    UserToken.start_link(:ok)
    UserSpew.start_link(:ok)
    UserTokenPermanent.start_link(:ok)
    UserTokenBroadcast.start_link(:ok)
  end
end
