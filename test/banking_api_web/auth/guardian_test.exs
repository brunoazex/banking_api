# test/banking_api_web/auth/guardian_test.exs

defmodule BankingApi.GuardianTest do
  use BankingApi.DataCase

  alias BankingApiWeb.Auth.Guardian

  import BankingApi.Test.Factories.Factory

  setup do
    [persisted: insert(:account)]
  end

  describe "token" do
    test "subject creation", %{persisted: persisted} do
      assert  Guardian.subject_for_token(persisted, nil) == {:ok, to_string(persisted.id) }
    end

    test "resource from claims", %{persisted: persisted} do
      {:ok, _, claims } = Guardian.encode_and_sign(persisted)
      assert {:ok, account} = Guardian.resource_from_claims(claims)
    end
  end

  describe "authentication" do
    test "with valid credential", %{persisted: persisted} do
      assert {:ok, account, token} = Guardian.authenticate(persisted.number, "12345678")
    end
  end
end
