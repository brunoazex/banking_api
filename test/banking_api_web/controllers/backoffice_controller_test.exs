# test/banking_api_web/controllers/backoffice_controller_test.exs

defmodule BankingApiWeb.BackOfficeControllerTest do
  use BankingApiWeb.ConnCase

  @account_attrs %{name: "Regular user", email: "regular@user.com", document: "000.000.000-00", password: "12345678"}
  setup do
    conn = build_conn()
    conn = post(conn, Routes.registration_path(conn, :create), @account_attrs)
    logged = json_response(conn, 201)
    [logged: logged]
  end

  describe "statements" do
    test "get statements", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/backoffice/volume", %{"from_date"=> "2020-01-01", "to_date" => "2020-01-03"})
      assert json_response(conn, 200) != %{}
    end
  end
end
