# test/banking_api_web/controllers/banking_controller_test.exs

defmodule BankingApiWeb.BankingControllerTest do
  use BankingApiWeb.ConnCase

  @account_attrs %{name: "Regular user", email: "regular@user.com", document: "000.000.000-00", password: "12345678"}
  setup do
    conn = build_conn()
    conn = post(conn, Routes.registration_path(conn, :create), @account_attrs)
    logged = json_response(conn, 201)

    conn = build_conn()
    conn = post(conn, Routes.registration_path(conn, :create), @account_attrs)
    acc_b = json_response(conn, 201)

    [logged: logged, acc_b: acc_b]
  end

  describe "statements" do
    test "get statements", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> get("/api/statements", %{"from_date"=> "2020-01-01", "to_date" => "2020-01-03"})
      assert json_response(conn, 200) != %{}
    end
  end

  describe "operations" do
    test "make a withdraw", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> post("/api/withdraw", %{"amount"=> 500})
      response = json_response(conn, 200)
      assert response != %{}
      assert response["amount"] == 500
      assert response["type"] == "withdraw"
      assert response["operation"] == "debt"
    end

    test "make a withdraw beyond balance available", %{conn: conn, logged: logged} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> post("/api/withdraw", %{"amount"=> 1250})
      assert json_response(conn, 405) != %{}
    end

    test "make a transfer", %{conn: conn, logged: logged, acc_b: acc_b} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> post("/api/transfer", %{"destination" => acc_b["account"], "amount"=> 250})
      response = json_response(conn, 200)
      assert response != %{}
      assert response["amount"] == 250
      assert response["type"] == "transfer"
      assert response["operation"] == "debt"
    end

    test "make a transfer beyond balance available", %{conn: conn, logged: logged, acc_b: acc_b} do
      conn = conn
      |> put_req_header("authorization", "Bearer #{logged["token"]}")
      |> post("/api/transfer", %{"destination" => acc_b["account"], "amount"=> 1250})
      assert json_response(conn, 405) != %{}
    end
  end

end
