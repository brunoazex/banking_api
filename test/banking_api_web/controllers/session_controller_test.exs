# test/banking_api_web/controllers/sessions_controller_test.exs

defmodule BankingApiWeb.SessionControllerTest do
  use BankingApiWeb.ConnCase

  @account_attrs %{name: "Regular user", email: "regular@user.com", document: "000.000.000-00", password: "12345678"}
  setup do
    conn = build_conn()
    conn = post(conn, Routes.registration_path(conn, :create), @account_attrs)
    response = json_response(conn, 201)
    [logged: response]
  end

  describe "signin" do
    test "renders token when credential is valid",  %{conn: conn, logged: logged} do
      conn = post(conn, Routes.session_path(conn, :create), %{"account" => logged["account"], "password" => "12345678"})
      assert %{"customer" => name} = json_response(conn, 201)
    end

    test "renders error when account not found", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), %{"account" => "000000", "password" => "1234567x8"})
      assert json_response(conn, 404) != %{}
    end

    test "renders error when password is invalid", %{conn: conn, logged: logged} do
      conn = post(conn, Routes.session_path(conn, :create), %{"account" => logged["account"], "password" => "12345678x"})
      assert json_response(conn, 401) != %{}
    end

    test "renders error with wrong parameters", %{conn: conn, logged: logged} do
      conn = post(conn, Routes.session_path(conn, :create), %{"accountx" => logged["account"], "password" => "12345678x"})
      assert json_response(conn, 400) != %{}
    end
  end

  describe "signout" do
    test "with valid token", %{conn: conn, logged: logged} do
      conn = put_req_header(conn, "authorization", "Bearer #{logged["token"]}")
      conn = delete(conn, "/api/signout")
      assert json_response(conn, 200) != %{}
    end

    test "with no token", %{conn: conn} do
      conn = delete(conn, "/api/signout")
      assert json_response(conn, 401) != %{}
    end
  end
end
