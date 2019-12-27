defmodule BankingApi.AccountsTest do
  use BankingApi.DataCase
  alias BankingApi.Accounts

  describe "account" do
    alias BankingApi.Accounts.Account

    @valid_attrs %{name: "Regular user", email: "regular@user.com", document: "000.000.000-00", password: "some password_hash"}
    @invalid_attrs %{name: nil, document: nil, email: nil, password: nil}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_account()
      %{account | password: nil}
    end

    test "list_account/0 returns all account" do
      account = account_fixture()
      assert Accounts.list_account() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "get_by_number!/1 returns the account with given number" do
      account = account_fixture()
      with {:ok, acc} <- Accounts.get_account_by_number(account.number) do
        assert acc == account
      end
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Accounts.create_account(@valid_attrs)
      assert account.name == "Regular user"
      assert account.email == "regular@user.com"
      assert account.document == "000.000.000-00"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end

  end
end
