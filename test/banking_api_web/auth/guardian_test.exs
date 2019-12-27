defmodule BankingApi.GuardianTest do
  use BankingApi.DataCase
  alias BankingApi.Accounts
  alias BankingApiWeb.Auth.Guardian

  @account %{name: "Regular user", email: "regular@user.com", document: "000.000.000-00", password: "12345678"}
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(@account)
      |> Accounts.create_account()
      %{account | password: nil}
  end
  describe "token" do
    test "subject creation" do
      account = account_fixture()
      assert  Guardian.subject_for_token(account, nil) == {:ok, to_string(account.id) }
    end

    test "resource from claims" do
      account = account_fixture()
      {:ok, _, claims } = Guardian.encode_and_sign(account)
      assert {:ok, account} = Guardian.resource_from_claims(claims)
    end
  end

  describe "authentication" do
    test "with valid credential" do
      account = account_fixture()
      assert {:ok, account, token} = Guardian.authenticate(account.number, "12345678")
    end
  end
end
