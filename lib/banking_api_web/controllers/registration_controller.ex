defmodule BankingApiWeb.RegistrationController do
  @moduledoc """
  Account registration controller
  """
  use BankingApiWeb, :controller
  alias BankingApi.Accounts
  alias BankingApiWeb.Auth.Guardian

  action_fallback BankingApiWeb.FallbackController

  def create(conn, %{} = account_params) do
    with {:ok, account} <- Accounts.create_account(account_params),
    {:ok, token, _claims} <- Guardian.encode_and_sign(account) do
      conn
      |> put_status(:created)
      |> put_view(BankingApiWeb.AccountView)
      |> render("account.json", account: account, token: token)
    end
  end
end
