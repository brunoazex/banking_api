defmodule BankingApiWeb.CustomerControllerTest do
  use BankingApiWeb.ConnCase
  alias BankingApi.Accounts
  alias BankingApiWeb.Auth.Guardian

  @account_model %{name: "Regular user", email: "regular@user.com", document: "000.000.000-00", password: "12345678"}
  setup do
    account = account_fixture()
    {:ok, jwt, full_claims} = Guardian.encode_and_sign(account)
    {:ok, %{account: account, jwt: jwt, claims: full_claims}}
  end

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(@account_model)
      |> Accounts.create_account()
      %{account | password: nil}
  end

  describe "signin" do
    test "renders token when credential is valid",  %{conn: conn, account: account} do
      conn = post(conn, Routes.session_path(conn, :create), %{"account" => account.number, "password" => "12345678"})
      assert %{"customer" => name} = json_response(conn, 201)
    end

    test "renders error when account not found", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), %{"account" => "000000", "password" => "1234567x8"})
      assert json_response(conn, 404) != %{}
    end

    test "renders error when password is invalid", %{conn: conn, account: account} do
      conn = post(conn, Routes.session_path(conn, :create), %{"account" => account.number, "password" => "12345678x"})
      assert json_response(conn, 401) != %{}
    end

    test "renders error with wrong parameters", %{conn: conn, account: account} do
      conn = post(conn, Routes.session_path(conn, :create), %{"accountx" => account.number, "password" => "12345678x"})
      assert json_response(conn, 400) != %{}
    end
  end

  describe "signout" do
    test "with valid token", %{conn: conn, jwt: jwt} do
      conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
      conn = delete(conn, "/api/signout")
      assert json_response(conn, 200) != %{}
    end

    test "with no token", %{conn: conn} do
      conn = delete(conn, "/api/signout")
      assert json_response(conn, 401) != %{}
    end
  end
end
