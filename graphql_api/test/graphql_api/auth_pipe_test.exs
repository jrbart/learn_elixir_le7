defmodule GraphqlApi.AuthPipeTest do
  use GraphqlApi.DataCase

  alias GraphqlApi.AccountFactory, as: AF
  alias GraphqlApi.Users
  alias GraphqlApi.AuthPipe

  describe "pipeline runs" do
    setup _cxt do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)

      %{user_id: user.id}
    end

    test "creates and stores a user token", ctx do
      :ok = AuthPipe.run([ctx.user_id])

      token = Users.get_token_by_id(ctx.user_id)
      refute is_nil(token)
    end
  end
end
