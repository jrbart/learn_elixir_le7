defmodule GraphqlApi.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      @endpoint GraphqlApiWeb.Endpoint
    end
  end
end
