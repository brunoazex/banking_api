# lib/banking_api_web/controllers/backoffice_controller.ex

defmodule BankingApiWeb.BackOfficeController do
  @moduledoc """
  BackOffice End point controller
  """
  use BankingApiWeb, :controller

  alias BankingApi.Banking

  action_fallback BankingApiWeb.FallbackController

  def index(conn, %{"from_date" => from_date, "to_date" => to_date}) do
    {:ok, total_amount } = Banking.get_total_amount(from_date, to_date)
    conn
    |> put_status(:ok)
    |> put_view(BankingApiWeb.BackOfficeView)
    |> render("index.json", %{start_date: from_date, end_date: to_date, total_amount: total_amount})
  end
end
