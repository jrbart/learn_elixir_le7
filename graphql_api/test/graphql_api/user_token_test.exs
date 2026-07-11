defmodule GraphqlApi.UserTokenTest do
  use GraphqlApi.DataCase

  alias GraphqlApi.AccountFactory, as: AF
  alias GraphqlApi.Users

  describe "@UserToken" do
    test "stores token" do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)

      {:ok, res} = Users.update_token(user.id, "test")

      assert res.token == "test"
    end

    test "replaces token" do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)

      # I'm testing this because I'm using an "upsert"
      # that first tries an insert and then does an update 
      # if the insert fails because of a failed unique user_id
      # to make sure the storage is an atomic operation

      {:ok, _res} = Users.update_token(user.id, "token1")
      {:ok, res} = Users.update_token(user.id, "token2")

      assert res.token == "token2"
    end
  end
end
