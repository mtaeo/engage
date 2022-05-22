# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :engage,
  ecto_repos: [Engage.Repo]

# Configures the endpoint
config :engage, EngageWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: EngageWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Engage.PubSub,
  live_view: [signing_salt: "3TWw6rAt"]

# Configures the mailer
config :engage, Engage.Mailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: "eu-south-1",
  access_key: System.get_env("AWS_ACCESS_KEY_ID"),
  secret: System.get_env("AWS_SECRET_ACCESS_KEY")

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, Swoosh.ApiClient.Hackney

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Configure Tailwind CSS
config :tailwind,
  version: "3.0.23",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure ueberauth
config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user,user:email"]},
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]},
    discord: {Ueberauth.Strategy.Discord, [default_scope: "identify email connections guilds"]},
    facebook: {Ueberauth.Strategy.Facebook, [default_scope: "email,public_profile"]},
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

# Configure ueberauth Github strategy
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Configure ueberauth Google strategy
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Configure ueberauth Discord strategy
config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
  client_id: System.get_env("DISCORD_CLIENT_ID"),
  client_secret: System.get_env("DISCORD_CLIENT_SECRET")

# Configure ueberauth Facebook strategy
config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("FACEBOOK_CLIENT_SECRET")

# Configure ueberauth Twitter strategy
config :ueberauth, Ueberauth.Strategy.Twitter.OAuth,
  consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
  consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
