# test/banking_api/accounts_test.exs

defmodule BankingApi.AccountsTest do
  use BankingApi.DataCase

  alias BankingApi.Accounts

  import BankingApi.Test.Factories.Factory

  @equality_fields [:name, :document, :email]

  setup do
     [persisted: insert(:account)]
  end

  describe "accounts" do
    test "returns the account with given id", %{persisted: persisted} do
      with {:ok, retrieved} <- Accounts.get_by_id(persisted.id) do
        assert are_equals(persisted, retrieved)
      end
    end

    test "returns the account with given number", %{persisted: persisted} do
     with {:ok, retrieved} <- Accounts.get_by_number(persisted.number) do
      assert are_equals(persisted, retrieved)
      end
    end

    test "returns a new account after signup" do
      signup_attrs = %{name: "New user", email: "new@user.com", document: "000", password: "12345678"}
      {:ok, signed_up } =
        signup_attrs
          |> Accounts.signup()
      assert are_equals(signed_up, signup_attrs)
      assert signed_up.balance == 1000
      assert signed_up.number != nil
      assert [%{description: "Signup bonus", amount: 1000}] = signed_up.transactions
    end
  end

  defp are_equals(account1, account2) do
    acc_1 =
      account1
        |> Map.take(@equality_fields)

    acc_2 =
      account2
        |> Map.take(@equality_fields)

    acc_1 == acc_2
  end

end
