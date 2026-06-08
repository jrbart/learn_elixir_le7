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

      setup context do
        # Assume all tests are running with admin role
        socket_params = Map.get(context, :socket_params, %{role: :admin})

        {:ok, socket} = Phoenix.ChannelTest.connect(GraphqlApiWeb.UserSocket, socket_params)
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

        {:ok, %{socket: socket}}
      end
    end
  end
end
