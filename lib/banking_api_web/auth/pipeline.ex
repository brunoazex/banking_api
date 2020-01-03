# lib/banking_api_web/auth/pipeline.ex

defmodule BankingApiWeb.Auth.Pipeline do
  @moduledoc """
  Guardian integration into a pipeline
  """
  use Guardian.Plug.Pipeline, otp_app: :banking_api,
      module: BankingApiWeb.Auth.Guardian,
      error_handler: BankingApiWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug BankingApiWeb.Auth.CurrentAccount
end
