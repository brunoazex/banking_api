# lib/banking_api_web/controllers/session_controller.ex

defmodule BankingApiWeb.SessionController do
  use BankingApiWeb, :controller

  alias BankingApiWeb.Auth.Guardian

  action_fallback BankingApiWeb.FallbackController

  def create(conn, %{"account" => account_number, "password" => password}) do
    with {:ok, account, token} <- Guardian.authenticate(account_number, password) do
      conn
      |> put_status(:created)
      |> put_view(BankingApiWeb.AccountView)
      |> render("account.json", account: account, token: token)
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> put_view(BankingApiWeb.ErrorView)
    |> render(:"400")
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_status(200)
    |> put_view(BankingApiWeb.ErrorView)
    |> render(:"200")
  end
end
