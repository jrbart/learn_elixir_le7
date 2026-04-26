defmodule GraphqlApiWeb.Schema.MutationsTest do
  use GraphqlApi.DataCase

  alias GraphqlApi.AccountFactory, as: AF
  alias GraphqlApi.Accounts.Preference
  alias GraphqlApiWeb.Schema
  alias GraphqlApi.Users

  @user_doc1 """
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

  describe "@createUser" do
    test "creates user" do
      name = "test"
      email = "test@example.com"

      res =
        Absinthe.run(@user_doc1, Schema,
          context: %{"role" => :admin},
          variables: %{"name" => name, "email" => email}
        )

      SharedUtils.Logger.debug(__MODULE__, Kernel.inspect(res))

      # check GraphQL response
      assert {:ok, %{data: %{"createUser" => user}}} = res
      assert %{"name" => ^name, "email" => ^email} = user

      # Cheack that database entry was actually created
      assert {:ok, user} = Users.get_by_id(user["id"])
      assert user.name == "test"
    end

    test "fails if missing email" do
      name = "test"

      res =
        Absinthe.run(@user_doc1, Schema,
          context: %{"role" => :admin},
          variables: %{"name" => name}
        )

      assert {:ok, %{errors: [%{message: error}]}} = res
      assert "email: can't be blank" = error
    end

    test "fails if duplicate email" do
      name = "test"
      email = "test@example.com"

      _res =
        Absinthe.run(@user_doc1, Schema,
          context: %{"role" => :admin},
          variables: %{"name" => name, "email" => email}
        )

      res =
        Absinthe.run(@user_doc1, Schema,
          context: %{"role" => :admin},
          variables: %{"name" => name, "email" => email}
        )

      assert {:ok, %{errors: [%{message: error}]}} = res
      assert "email: invalid email address" = error
    end
  end

  @user_doc2 """
    mutation UpdateUser($id: ID!, $name: String, $email: String){
      updateUser(id: $id, name: $name, email: $email) {
        id
        name
        email
      }
    }
  """

  describe "@updateUser" do
    test "updates name and email" do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)

      assert {:ok, %{data: data}} =
               Absinthe.run(@user_doc2, Schema,
                 context: %{"role" => :admin},
                 variables: %{
                   "id" => user.id,
                   "name" => "new_name",
                   "email" => "new_email@example.com"
                 }
               )

      # check GraphQL response
      assert data["updateUser"]["name"] == "new_name"
      assert data["updateUser"]["email"] == "new_email@example.com"

      # check that database was update
      {:ok, user} = Users.get_by_id(user.id)
      assert user.name == "new_name"
    end

    test "fails correctly with bad ID" do
      user_id = 0

      assert res =
               Absinthe.run(@user_doc2, Schema,
                 context: %{"role" => :admin},
                 variables: %{
                   "id" => user_id,
                   "name" => "new_name",
                   "email" => "new_email@example.com"
                 }
               )

      # check GraphQL response
      assert {:ok, %{errors: [%{message: error}]}} = res
      assert "id: not found" = error
    end

    test "fails correctly with invalid data" do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)

      assert res =
               Absinthe.run(@user_doc2, Schema,
                 context: %{"role" => :admin},
                 variables: %{
                   "id" => user.id,
                   "name" => "new_name",
                   "email" => "new_email"
                 }
               )

      # check GraphQL response
      assert {:ok, %{errors: [%{message: error}]}} = res
      assert "email: has invalid format" = error
    end
  end

  @user_doc3 """
    mutation UpdateUserPrefs($id: ID!, $calls: Boolean, $emails: Boolean, $faxes: Boolean){
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

  describe "@updateUserPreferences" do
    test "updates single pref" do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)

      assert {:ok, %{data: data}} =
               Absinthe.run(@user_doc3, Schema,
                 context: %{"role" => :admin},
                 variables: %{
                   "id" => user.id,
                   "emails" => true
                 }
               )

      # check GraphQL response
      assert data["updateUserPreferences"]["likesEmails"] == true
    end

    test "updates multiple prefs" do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)

      assert {:ok, %{data: data}} =
               Absinthe.run(@user_doc3, Schema,
                 context: %{"role" => :admin},
                 variables: %{
                   "id" => user.id,
                   "emails" => true,
                   "calls" => true,
                   "faxes" => true
                 }
               )

      # check GraphQL response
      assert data["updateUserPreferences"]["likesEmails"] == true
      assert data["updateUserPreferences"]["likesPhoneCalls"] == true
      assert data["updateUserPreferences"]["likesFaxes"] == true

      # check that database was updated
      prefs = Repo.get!(Preference, user.id)
      assert prefs.likes_phone_calls == true
      assert prefs.likes_emails == true
      assert prefs.likes_faxes == true
    end

    test "fails correctly with bad ID" do
      user_id = 0

      assert res =
               Absinthe.run(@user_doc3, Schema,
                 context: %{"role" => :admin},
                 variables: %{
                   "id" => user_id,
                   "emails" => true
                 }
               )

      # check GraphQL response
      assert {:ok, %{errors: [%{message: error}]}} = res
      assert "id: not found" = error
    end
  end

  describe "@Authheader" do
    test "mutations should fail if the auth token is not supplied" do
      name = "test"
      email = "test@example.com"

      res =
        Absinthe.run(@user_doc1, Schema, variables: %{"name" => name, "email" => email})

      SharedUtils.Logger.debug(__MODULE__, Kernel.inspect(res))

      # check GraphQL response looks like:
      # %{data: %{"createUser" => nil}, errors: [%{code: :not_acceptable, ...}]}}
      assert {:ok, %{errors: errors}} = res
      assert [%{code: :not_acceptable} | _] = errors
    end
  end
end
