# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url = {:system, "DATABASE_URL"}

config :banking_api, BankingApi.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base = {:system, "SECRET_KEY_BASE"}

config :banking_api, BankingApi.Endpoint,
  server: true,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  url: [host: System.get_env("HOST"), scheme: "https", port: 443],
  secret_key_base: secret_key_base,
  http: [:inet6, port: System.get_env("PORT")]
