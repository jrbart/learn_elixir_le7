defmodule GraphqlApiWeb.Schema.Subscriptions.UserAuthTokenTest do
  use GraphqlApi.DataCase
  use ExUnit.Case, async: false
  use GraphqlApiWeb.SubscriptionCase

  alias GraphqlApi.Users
  alias GraphqlApi.AuthPipe

  alias GraphqlApi.AccountFactory, as: AF

  @token_notify_doc """
  subscription($id: ID!) { 
    userAuthToken( user_id: $id) 
    {
      auth_token
    }
  }
  """

  describe "@notify_token" do
    @tag authed: true
    setup _cxt do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)

      %{user_id: user.id}
    end

    test "gets triggered by AuthPipe pipeline", %{socket: socket, user_id: user_id} do
      # subscribe
      ref =
        push_doc(socket, @token_notify_doc,
          variables: %{
            "id" => user_id
          }
        )

      # test subscription reply and get subscription id 
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      # run the pipeline 
      :ok = AuthPipe.run([user_id])

      # get new token
      {:ok, token} = Users.get_token_by_id(user_id)

      # check subscription push 
      assert_push "subscription:data", %{subscriptionId: ^subscription_id, result: %{data: data}}
      # check that we got the new token
      assert %{"userAuthToken" => %{"auth_token" => ^token}} = data
    end
  end
end
