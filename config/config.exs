# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cat_show,
  ecto_repos: [CatShow.Repo]

# Configures the endpoint
config :cat_show, CatShowWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hWkpkh+mpoPhOa/l0jlORfSDC1S8Ex8ghKDMFVnsjQle69r6lVeWXngmyMglGv1b",
  render_errors: [view: CatShowWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CatShow.PubSub,
           adapter: Phoenix.PubSub.PG2]


config :cat_show, CatShow.Auth.Guardian,
  issuer: "cat_show",
  secret_key: "#{Mix.env}"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
