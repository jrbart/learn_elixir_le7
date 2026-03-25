defmodule GraphqlApiWeb.Schema.SubscriptionsTest do
  use GraphqlApi.DataCase
  use ExUnit.Case, async: false
  use GraphqlApiWeb.SubscriptionCase

  alias GraphqlApi.Users
  alias GraphqlApi.AccountFactory, as: AF

  @create_user_doc """
  mutation CreateUser($name: String, $email: String){
    createUser(name: $name, email: $email, preferences: {
      likesEmails: true, 
      likesPhoneCalls: true,
      likesFaxes: true
    }) {
      id
      name
      email
      preferences {
        likesEmails
        likesPhoneCalls
        likesFaxes
      }
    }
  }
  """

  @created_user_doc """
  subscription CreatedUser {
    createdUser {
      id
      preferences {
        likesEmails
      }
    }
  }
  """

  describe "@createdUser" do
    test "gets triggered by @creatUser mutations", %{socket: socket} do
      # subscribe
      ref = push_doc(socket, @created_user_doc)

      # test subscription reply
      # and get subscription id 
      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      # send create mutation
      name = "test"
      email = "test@example.com"
      ref = push_doc(socket, @create_user_doc, %{variables: %{"name" => name, "email" => email}})

      # check mutation results
      # mutation tests already check various combinations of returns,
      # we just check that we get an :ok reply and get the id
      assert_reply ref, :ok, %{data: data}
      assert %{"createUser" => %{"id" => id}} = data

      # check subscription push 
      assert_push "subscription:data", %{subscriptionId: ^subscription_id, result: %{data: data}}
      assert %{"createdUser" => %{"id" => ^id, "preferences" => %{"likesEmails" => true}}} = data
      # note: checking preferences to make sure DataLoader works when 
      # sending results to subscriptions.
    end

    # note: we could check that invalid createUser attempts do not
    # trigger subscriptions, but that is being pedantic here.
  end

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
