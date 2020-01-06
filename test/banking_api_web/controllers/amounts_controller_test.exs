# test/banking_api_web/controllers/backoffice_controller_test.exs

defmodule BankingApiWeb.AmountsControllerTest do
  use BankingApiWeb.ConnCase

  @account_attrs %{name: "Regular user", email: "regular@user.com", document: "000.000.000-00", password: "12345678"}
  setup do
    conn = build_conn()
    conn = post(conn, Routes.registration_path(conn, :create), @account_attrs)
    logged = json_response(conn, 201)
    [logged: logged]
  end

  describe "volumes" do
    test "get by period", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/interval", %{"from_date"=> "2020-01-01", "to_date" => "2020-01-03"})
      assert json_response(conn, 200) != %{}
    end

    test "get by period with invalid from_date", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/interval", %{"from_date"=> "2020-01-013", "to_date" => "2020-01-03"})
      assert json_response(conn, 422) != %{}
    end

    test "get by period with invalid to_date", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/interval", %{"from_date"=> "2020-01-013", "to_date" => "2020-01-03"})
      assert json_response(conn, 422) != %{}
    end

    test "get by period with to_date greater than from_date", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/interval", %{"from_date"=> "2020-01-06", "to_date" => "2020-01-01"})
      assert json_response(conn, 422) != %{}
    end

    test "get by month", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/month", %{"month"=> 1, "year" => 2020})
      assert json_response(conn, 200) != %{}
    end

    test "get by month with invalid month", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/month", %{"month"=> 13, "year" => 2020})
      assert json_response(conn, 422) != %{}
    end

    test "get by month with invalid year", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/month", %{"month"=> 1, "year" => 20201})
      assert json_response(conn, 422) != %{}
    end

    test "get by year", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/year", %{"year"=> 2020})
      assert json_response(conn, 200) != %{}
    end

    test "get by year with invalid year", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/reports/amounts/year", %{"year"=> 20201})
      assert json_response(conn, 422) != %{}
    end
  end
end
