defmodule GraphqlApiWeb.SubscriptionCase do
  @moduledoc """
  Test case for GraphQK subscription
  """
  require Phoenix.ChannelTest

  use ExUnit.CaseTemplate

  using do
    quote do
      use GraphqlApi.ChannelCase

      use Absinthe.Phoenix.SubscriptionTest,
        schema: GraphqlApiWeb.Schema

      setup do
        {:ok, socket} = Phoenix.ChannelTest.connect(GraphqlApiWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

        {:ok, %{socket: socket}}
      end
    end
  end
end
