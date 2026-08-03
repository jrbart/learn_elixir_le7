defmodule GraphqlApi.UsersTest do
  use GraphqlApi.DataCase

  alias GraphqlApi.AccountFactory, as: AF
  alias GraphqlApi.Users

  describe "@Users" do
    # make sure that a token is created when user is created
    test "&create_user/1" do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)
      {:ok, token} = Users.get_token_by_id(user.id)

      assert token == "change_me"
    end
  end
end
