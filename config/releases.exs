# config/releases.exs

# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

database_url = System.get_env("DATABASE_URL")

config :banking_api, BankingApi.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base = System.get_env("SECRET_KEY_BASE")

config :banking_api, BankingApiWeb.Endpoint,
  http: [port:  System.get_env("PORT")],
  load_from_systen_env: true,
  url: [scheme: "https", host: "azex-banking-api.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  server: true,
  secret_key_base: secret_key_base,
  render_errors: [view: BankingApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BankingApi.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger,
       backends: [Timber.LoggerBackends.HTTP, :console],
       level: :info

config :timber,
       api_key: System.get_env("TIMBER_API_KEY"),
       source_id: System.get_env("TIMBER_SOURCE_ID")

config :banking_api, BankingApi.Mailer,
       adapter: Bamboo.SendGridAdapter,
       api_key: System.get_env("SENDGRID_API_KEY")

config :banking_api, BankingApiWeb.Auth.Guardian,
  issuer: "banking_api",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")
