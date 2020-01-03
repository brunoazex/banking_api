# test/banking_api_web/auth/current_account_test.exs

defmodule BankingApiWeb.CurrentAccountTest do

  use BankingApiWeb.ConnCase

  import BankingApi.Test.Factories.Factory

  alias BankingApiWeb.Auth.CurrentAccount
  alias BankingApiWeb.Auth.Guardian

  setup do
    account = insert(:account)
    [account: %{account | password: nil}]
  end

  describe "current user plug" do
    test "current user is set", %{conn: conn, account: account} do
      conn = conn
      |> Guardian.Plug.sign_in(account)
      |> CurrentAccount.call(%{})
      assert conn.assigns.current_account == account
    end

    test "current user is not set", %{conn: conn} do
      conn = conn
      |> CurrentAccount.call(%{})
      assert conn.assigns[:current_account] == nil
    end
  end
end
