defmodule GraphqlApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Config

  use Application

  @impl true
  def start(_type, _args) do
    if Application.get_env(:graphql_api, :env) == :test, do: IO.puts("\n\n\n\n\n")

    children = [
      GraphqlApi.Repo,
      GraphqlApiWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:graphql_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GraphqlApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GraphqlApi.Finch},
      # Start a worker by calling: GraphqlApi.Worker.start_link(arg)
      # {GraphqlApi.Worker, arg},
      # Start to serve requests, typically the last entry
      GraphqlApiWeb.Endpoint,
      {Absinthe.Subscription, pubsub: GraphqlApiWeb.Endpoint},
      GraphqlApi.Scheduler,
      {GraphqlApi.HitCounter, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GraphqlApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GraphqlApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
