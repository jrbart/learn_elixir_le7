defmodule GraphqlApiWeb.Schema.Subscription.UpdatedUserPreferencesTest do
  use GraphqlApi.DataCase
  use ExUnit.Case, async: false
  use GraphqlApiWeb.SubscriptionCase

  alias GraphqlApi.Users

  alias GraphqlApi.AccountFactory, as: AF

  @update_user_prefs_doc """
  mutation UpdateUserPreferences($id: ID!, $calls: Boolean, $emails: Boolean, $faxes: Boolean){
    updateUserPreferences(
      userId: $id, 
      likesPhoneCalls: $calls,
      likesEmails: $emails,
      likesFaxes: $faxes
      ) {
      likesPhoneCalls
      likesEmails
      likesFaxes
    }
  }
  """

  @updated_user_prefs_doc """
  subscription($id: ID!) {
    updatedUserPreferences(userId: $id)
    {
      likesEmails
    }
  }
  """

  describe "@updatedUserPreferences" do
    test "gets triggered by @updateUserPreferences mutation", %{socket: socket} do
      # create a user for the test 
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)
      # by default, all preferences are false...

      # subscribe
      ref =
        push_doc(socket, @updated_user_prefs_doc,
          variables: %{
            id: user.id
          }
        )

      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      # send create mutation
      ref =
        push_doc(socket, @update_user_prefs_doc,
          variables: %{
            "id" => user.id,
            "emails" => true
          }
        )

      # check mutation results
      assert_reply ref, :ok, %{data: data}
      assert %{"updateUserPreferences" => %{"likesEmails" => true}} = data

      # check subscription push 
      assert_push "subscription:data", %{subscriptionId: ^subscription_id, result: %{data: data}}
      assert %{"updatedUserPreferences" => %{"likesEmails" => true}} = data
    end
  end
end
