defmodule GraphqlApi.UsersTest do
  use ExUnit.Case
  use Mimic.DSL
  use GraphqlApi.RepoMock
  alias GraphqlApi.Users

  describe "&get_by_prefs" do
    # Instead of calling the database function, we want to investigate the query
    # so our mock will return the partion that we are interested in
    setup ctx do
      repo_mock = ctx[:mock]
      expect repo_mock.all(query), do: query

      :ok
    end

    test "correctly adds where conditions to the query" do
      {:ok, query} = Users.get_by_prefs(%{likes_emails: true, likes_faxes: false})
      meta_where = query.wheres
      # This test is fragile because it depends on the two condition clauses
      # being returned in this order and there is no guarantee on the order.
      # It could be made independant of order without too much hassle, but
      # it works for now so I keep it simple.
      [c1, c2] = meta_where

      assert c1.params == [true: {1, :likes_emails}]
      assert c2.params == [false: {1, :likes_faxes}]
    end

    test "correctly adds limit restrictions to the query" do
      {:ok, query} = Users.get_by_prefs(%{first: 9, after: 99})
      [c1] = query.wheres
      l1 = query.limit

      assert c1.params == [{99, {0, :id}}]
      assert l1.params == [{9, :integer}]
    end
  end
end
