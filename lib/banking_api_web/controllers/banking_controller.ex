# lib/banking_api_web/controllers/banking_controller.ex

defmodule BankingApiWeb.BankingController do
  use BankingApiWeb, :controller

  alias BankingApi.Banking
  alias BankingApiWeb.Auth.Guardian

  action_fallback BankingApiWeb.FallbackController

  def index(conn, %{"from_date" => from_date, "to_date" => to_date}) do
    account = Guardian.Plug.current_resource(conn)
    {:ok, statements} = Banking.get_statements(account.number, from_date, to_date)
    conn
    |> put_status(:ok)
    |> put_view(BankingApiWeb.BankingView)
    |> render("index.json", %{statements: statements, balance: account.balance})
  end

  def withdraw(conn, %{"amount"=> amount}) do
    account = Guardian.Plug.current_resource(conn)
    case Banking.withdraw(account.number, amount) do
      {:ok, transaction } ->
        conn
        |> put_status(:ok)
        |> put_view(BankingApiWeb.BankingView)
        |> render("statement.json", %{statement: transaction})
      {:error, :verify_balance, :balance_too_low} ->
        conn
        |> put_status(:method_not_allowed)
        |> put_view(BankingApiWeb.ErrorView)
        |> render("error.json", %{message: "Balance too low"})
    end
  end

  def transfer(conn, %{"destination"=> destination, "amount"=> amount}) do
    account = Guardian.Plug.current_resource(conn)
    case Banking.wire_transfer(account.number, destination, amount) do
      {:ok, transaction } ->
        conn
        |> put_status(:ok)
        |> put_view(BankingApiWeb.BankingView)
        |> render("statement.json", %{statement: transaction})
      {:error, :verify_balances, :balance_too_low} ->
        conn
        |> put_status(:method_not_allowed)
        |> put_view(BankingApiWeb.ErrorView)
        |> render("error.json", %{message: "Balance too low"})
    end
  end
end
