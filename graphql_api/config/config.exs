# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :graphql_api,
  ecto_repos: [GraphqlApi.Repo]

config :graphql_api,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :graphql_api, GraphqlApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: GraphqlApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: GraphqlApi.PubSub,
  live_view: [signing_salt: "H8m3FZGk"]

config :ecto_shorts,
  repo: GraphqlApi.Repo,
  error_module: EctoShorts.Actions.Error

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :graphql_api, GraphqlApi.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  colors: [enabled: true, debug: :cyan, error: :red, info: :yellow] # Set ANSI colors to be on when piping to less or more 

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
