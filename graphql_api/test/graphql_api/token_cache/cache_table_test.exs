defmodule GraphqlApi.TokenCache.CacheTableTest do
  alias GraphqlApi.TokenCache
  alias GraphqlApi.Users
  use GraphqlApi.DataCase

  alias GraphqlApi.AccountFactory, as: AF

  setup _ctx do
    account = AF.build(:account)
    {:ok, user} = Users.create_user(account)
    {:ok, user_token} = Users.update_token(user.id, "test")
    [user_id: user.id, user_token: user_token.token]
  end

  describe "returns token from db when cache disabled" do
    setup do
      :cache_off = TokenCache.CacheTable.disable_cache()
      :ok
    end

    test "{:get_token, id}", ctx do
      token = TokenCache.CacheTable.get_token(ctx[:user_id])
      assert token == ctx[:user_token]
    end
  end

  describe "returns token from cache when cache enabled" do
    setup do
      :cache_on = TokenCache.CacheTable.enable_cache()
      :ok
    end

    test "{:get_token, id}", ctx do
      # prime the cache
      _token = TokenCache.CacheTable.get_token(ctx[:user_id])
      # now for purpose of testing, change value in db...
      Users.update_token(ctx[:user_id], "xxxxx")
      # this should be from cache, not db
      token = TokenCache.CacheTable.get_token(ctx[:user_id])
      assert token == ctx[:user_token]
    end
  end
end
