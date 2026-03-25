defmodule GraphqlApiWeb.Schema.QueriesTest do
  use GraphqlApi.DataCase

  alias GraphqlApi.AccountFactory, as: AF
  alias GraphqlApiWeb.Schema
  alias GraphqlApi.Users

  @user_doc """
    query GetUser($id: ID!) {
      user(id: $id) {
        id
        email
        preferences {
          likesEmails
        }
      }
    }
  """

  describe "@user" do
    test "fetches user by id" do
      test_user = AF.build(:account)

      # do I want to depend on Users.create_user here
      # or use Repo.insert to directly set up the DB?
      {:ok, user} = Users.create_user(test_user)

      assert {:ok, %{data: data}} =
               Absinthe.run(@user_doc, Schema,
                 variables: %{
                   "id" => user.id
                 }
               )

      assert data["user"]["id"] == to_string(user.id)
    end
  end

  @users_doc1 """
    query GetUsers($limit: Int, $before: ID, $after: ID) {
      users(before: $before, after: $after, first: $limit) {
        id
        email
        preferences {
          likesEmails
        }
      }
    }
  """

  @users_doc2 """
    query GetUserz(
      $likesEmails: Boolean, 
      $likesPhoneCalls: Boolean,
      $likesFaxes: Boolean
    ) {
      users(
        likesEmails: $likesEmails, 
        likesPhoneCalls: $likesPhoneCalls,
        likesFaxes: $likesFaxes
      ) {
        id
        email
      }
    }
  """

  describe "@users" do
    # make a test user for every test in this block
    setup do
      test_user = AF.build(:account)
      assert {:ok, user} = Users.create_user(test_user)
      [user: user]
    end

    test "returns an nil if no matches" do
      assert {:ok, %{data: data}} = Absinthe.run(@users_doc1, Schema, variables: %{"limit" => 0})
      assert data["users"] == []
    end

    test "fetch limits work", %{user: user} do
      res =
        Absinthe.run(@users_doc1, Schema,
          variables: %{
            "before" => user.id + 1,
            "after" => user.id - 1,
            "limit" => 1
          }
        )

      # easier to unpack results with pattern matching than access behaviour
      assert {:ok, %{data: %{"users" => [%{"id" => id}]}}} = res
      assert String.to_integer(id) == user.id
    end

    test "fetches by single pref" do
      Enum.each(AF.build_8(:account), &Users.create_user/1)

      res =
        Absinthe.run(@users_doc2, Schema,
          variables: %{
            "likesEmails" => true
          }
        )

      assert {:ok, %{data: %{"users" => users}}} = res
      assert length(users) == 4
      # because half of the 8 users have default which is false, half are {true, _, _}
    end

    test "fetches by two prefs" do
      Enum.each(AF.build_8(:account), &Users.create_user/1)

      res =
        Absinthe.run(@users_doc2, Schema,
          variables: %{
            "likesEmails" => true,
            "likesPhoneCalls" => true
          }
        )

      assert {:ok, %{data: %{"users" => users}}} = res
      assert length(users) == 2
      # because half of the 8 users have default which is false a quarter are {true, true, _}
    end

    test "fetches by all prefs" do
      Enum.each(AF.build_8(:account), &Users.create_user/1)

      res =
        Absinthe.run(@users_doc2, Schema,
          variables: %{
            "likesEmails" => true,
            "likesPhoneCalls" => true,
            "likesFaxes" => true
          }
        )

      assert {:ok, %{data: %{"users" => users}}} = res
      assert length(users) == 1
      # because half of the 8 users have default which is false only one is {true, true, true}
    end

    test "fetches all if no prefs" do
      # will build 8 uses with combinations of like_x: true and like_x: false
      Enum.each(AF.build_8(:account), &Users.create_user/1)

      res = Absinthe.run(@users_doc2, Schema, variables: %{})

      assert {:ok, %{data: %{"users" => users}}} = res
      assert length(users) == 9
      # we have 8 combinations plus the one created in the automatic setup
    end
  end

  @resolver_hits_doc """
  query ResolverHits($key: String) {
    resolverHits(key: $key) 
  }
  """

  # note - these tests run async and could interfere with each other
  # through the counter Agent, so keep the assertions to relative checks
  describe "@resolverHits" do
    test "endpoint returns an integer" do
      res =
        Absinthe.run(@resolver_hits_doc, Schema,
          variables: %{
            "key" => "resolverHits"
          }
        )

      assert {:ok, %{data: %{"resolverHits" => hits}}} = res
      assert is_integer(hits)
    end

    test "increases each time it is hit" do
      res1 = Absinthe.run(@resolver_hits_doc, Schema, variables: %{"key" => "resolverHits"})
      assert {:ok, %{data: %{"resolverHits" => hits1}}} = res1

      res2 = Absinthe.run(@resolver_hits_doc, Schema, variables: %{"key" => "resolverHits"})
      assert {:ok, %{data: %{"resolverHits" => hits2}}} = res2

      assert hits1 < hits2
    end

    test "different keys have different counters" do
      res1 = Absinthe.run(@resolver_hits_doc, Schema, variables: %{"key" => "testKey"})
      assert {:ok, %{data: %{"resolverHits" => hits1}}} = res1
      res2 = Absinthe.run(@resolver_hits_doc, Schema, variables: %{"key" => "resolverHits"})
      assert {:ok, %{data: %{"resolverHits" => hits2}}} = res2
      res3 = Absinthe.run(@resolver_hits_doc, Schema, variables: %{"key" => "testKey"})
      assert {:ok, %{data: %{"resolverHits" => hits3}}} = res3
      res4 = Absinthe.run(@resolver_hits_doc, Schema, variables: %{"key" => "resolverHits"})
      assert {:ok, %{data: %{"resolverHits" => hits4}}} = res4

      # Checking the counter does not increase the counter for the key
      assert hits1 == hits3
      # But it does increase the counter for 'resolverHits'
      assert hits2 < hits4
    end
  end
end
