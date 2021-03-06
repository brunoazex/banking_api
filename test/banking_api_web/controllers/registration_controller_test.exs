# test/banking_api_web/controllers/account_controller_test.exs

defmodule BankingApiWeb.AccountControllerTest do
  use BankingApiWeb.ConnCase

  @account_model %{name: "Regular user", email: "regular@user.com", document: "000.000.000-00", password: "12345678"}

  describe "registration" do
    test "renders created account when data is valid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), @account_model)
      assert %{"customer" => name} = json_response(conn, 201)
    end

    test "error when missing params", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create))
      assert json_response(conn, 422) != %{}
    end

    test "renders errors when customer name not supplied", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), %{name: nil, email: "regular@user.com",
        document: "000.000.000-00", password: "12345678"})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when customer email not supplied", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), %{name: "Regular user", email: nil,
        document: "000.000.000-00", password: "12345678"})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when customer email format is invalid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), %{name: "Regular user", email: "uiadfhiuasid",
        document: "000.000.000-00", password: "12345678"})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when customer document not supplied", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), %{name: "Regular user", email: "regular@user.com",
        document: nil, password: "12345678"})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when customer password not supplied", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), %{name: "Regular user", email: "regular@user.com",
        document: "000.000.000-00", password: nil})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when customer password length < 6", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), %{name: "Regular user", email: "regular@user.com",
        document: "000.000.000-00", password: "12345"})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

end
