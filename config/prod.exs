# config/prod.exs

use Mix.Config

config :logger,
  backends: [Timber.LoggerBackends.HTTP, :console],
  level: :info

config :timber,
  api_key: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL2FwaS50aW1iZXIuaW8vIiwiZXhwIjpudWxsLCJpYXQiOjE1Nzc0OTAyMzksImlzcyI6Imh0dHBzOi8vYXBpLnRpbWJlci5pby9hcGlfa2V5cyIsInByb3ZpZGVyX2NsYWltcyI6eyJhcGlfa2V5X2lkIjo1ODU4LCJ1c2VyX2lkIjoiYXBpX2tleXw1ODU4In0sInN1YiI6ImFwaV9rZXl8NTg1OCJ9.jBtPR8N-U58fEu-XJj1f8O4bbRGxVh0rr8-2WXjzhho",
  source_id: "30699"
