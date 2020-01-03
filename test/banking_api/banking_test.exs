# test/banking_api/banking_test.exs

defmodule BankingApi.BankingTest do
  use BankingApi.DataCase

  import BankingApi.Test.Factories.Factory

  alias BankingApi.Accounts.Account
  alias BankingApi.Banking
  alias BankingApi.Transactions.Transaction

  setup do
    acc_a = insert(:account)
    acc_b = insert(:account, %{name: "Receiver", email: "receiver@user.com", document: "000", password: "12345678"})
    [acc_a: acc_a, acc_b: acc_b]
  end

  describe "backoffice" do
    test "get total amount" do
      assert {:ok, total_amount} = Banking.get_total_amount("2020-01-01", "2020-01-03")
    end

    test "get total amount with invalid from_date" do
      assert {:error, reason} = Banking.get_total_amount("2020-01-01x", "2020-01-03")
      assert reason == "from_date: invalid_format"
    end

    test "get total amount with invalid to_date" do
      assert {:error, reason} = Banking.get_total_amount("2020-01-01", "2020-01-030")
      assert reason == "to_date: invalid_format"
    end
  end

  describe "statements" do
    test "get total amount", %{acc_a: acc_a} do
      assert {:ok, transactions} = Banking.get_statements(acc_a.number, "2020-01-01", "2020-01-03")
    end

    test "get with invalid from_date", %{acc_a: acc_a} do
      assert {:error, reason} = Banking.get_statements(acc_a.number, "2020-01-010", "2020-01-03")
      assert reason == "from_date: invalid_format"
    end

    test "get with invalid to_date", %{acc_a: acc_a} do
      assert {:error, reason} = Banking.get_statements(acc_a.number, "2020-01-01", "2020-01-030")
      assert reason == "to_date: invalid_format"
    end
  end

  describe "operations" do
    test "withdraw 1000 on a valid account", %{acc_a: acc_a} do
      assert {:ok, transaction } = Banking.withdraw(acc_a.number, 1000)
      assert transaction.amount == 1000
      assert transaction.operation == :debt
      assert transaction.account_id == acc_a.id
    end

    test "withdraw 1000 on a invalid source account" do
      assert {:error, :retrieve_account, :account_not_found } = Banking.withdraw("99999", 1000)
    end
    test "withdraw 1001 on a valid account with 1000 balance", %{acc_a: acc_a} do
      assert {:error, :verify_balance, :balance_too_low } = Banking.withdraw(acc_a.number, 1001)
    end

    test "transfer 1000", %{acc_a: acc_a, acc_b: acc_b} do
      assert {:ok, transaction } = Banking.wire_transfer(acc_a.number, acc_b.number, 1000)
      assert transaction.amount == 1000
      assert transaction.operation == :debt
      assert transaction.account_id == acc_a.id
      account_1 = Repo.get(Account, acc_a.id)
      account_2 = Repo.get(Account, acc_b.id)
      assert account_1.balance == (acc_a.balance - transaction.amount)
      assert account_2.balance == (acc_b.balance + transaction.amount)
    end

    test "transfer 1001 on a valid account with 1000 balance", %{acc_a: acc_a, acc_b: acc_b} do
      assert {:error, :verify_balances, :balance_too_low } = Banking.wire_transfer(acc_a.number, acc_b.number, 1001)
    end

    test "transfer 1000 from a invalid account", %{acc_b: acc_b} do
      assert {:error, :retrieve_accounts, :account_not_found } = Banking.wire_transfer("99999", acc_b.number, 1000)
    end

    test "transfer 1000 to a invalid account", %{acc_a: acc_a} do
      assert {:error, :retrieve_accounts, :account_not_found } = Banking.wire_transfer(acc_a.number, "99999", 1000)
    end
  end
  describe "transactions" do
    test "creates valid", %{acc_a: account} do
      assert %Ecto.Changeset{valid?: true} = Transaction.changeset(%Transaction{},
        %{description: "OK", account: account, amount: 10, operation: :debt, type: :withdraw})
    end
  end
end
