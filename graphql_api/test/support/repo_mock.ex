defmodule GraphqlApi.RepoMock do
  use ExUnit.CaseTemplate
  # this mocks out calls for Ecto.Repo so we can examine what is being passed to thos calls
  # the calls are not returning mock results, instead they are returning their args so
  # that we can verify our context functions are formulating the correct calls

  using do
    quote do
      use GraphqlApi.DataCase
      use Mimic.DSL
      alias GraphqlApi

      # these 'break' the actual calls to remind us that we are mocking in tests...
      # they are overridden in the actual tests
      setup ctx do
        stub(GraphqlApi.Repo.all(_query), do: :stub)
        stub(GraphqlApi.Repo.update(_query), do: :stub)
        stub(GraphqlApi.Repo.one(_query), do: :stub)

        [mock: GraphqlApi.Repo]
      end
    end
  end
end
