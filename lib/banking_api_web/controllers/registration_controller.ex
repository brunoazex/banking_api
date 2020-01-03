# lib/banking_api_web/controllers/registration_controller.ex

defmodule BankingApiWeb.RegistrationController do
  @moduledoc """
  Account registration controller
  """
  use BankingApiWeb, :controller
  alias BankingApi.Accounts
  alias BankingApiWeb.Auth.Guardian

  action_fallback BankingApiWeb.FallbackController

  def create(conn, %{} = signup_params) do
    with {:ok, account} <- Accounts.signup(signup_params),
    {:ok, token, _claims} <- Guardian.encode_and_sign(account) do
      conn
      |> put_status(:created)
      |> put_view(BankingApiWeb.AccountView)
      |> render("account.json", account: account, token: token)
    end
  end
end
