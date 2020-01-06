# lib/banking_api_web/controllers/backoffice_controller.ex

defmodule BankingApiWeb.AmountsController do
  @moduledoc """
  BackOffice End point controller
  """
  use BankingApiWeb, :controller
  use Timex

  alias BankingApi.Banking

  action_fallback BankingApiWeb.FallbackController

  def by_interval(conn, %{"from_date" => from_date, "to_date" => to_date}) do
    with {:ok, total_amount } <- Banking.get_total_amount(from_date, to_date) do
      conn
      |> put_status(:ok)
      |> put_view(BankingApiWeb.AmountsView)
      |> render("index.json", %{start_date: from_date, end_date: to_date, total_amount: total_amount})
    end
  end

  def by_month(conn, %{"month" => month, "year"=> year}) do
    with {:ok, start_date, end_date} <- create_month_period(month, year),
         {:ok, total_amount } <- Banking.get_total_amount(start_date, end_date)
    do
      conn
      |> put_status(:ok)
      |> put_view(BankingApiWeb.AmountsView)
      |> render("index.json", %{start_date: start_date, end_date: end_date, total_amount: total_amount})
    end
  end

  def by_year(conn, %{"year" => year}) do
    with {:ok, start_date, end_date} <- create_year_period(year),
         {:ok, total_amount } = Banking.get_total_amount(start_date, end_date)
    do
      conn
      |> put_status(:ok)
      |> put_view(BankingApiWeb.AmountsView)
      |> render("index.json", %{start_date: start_date, end_date: end_date, total_amount: total_amount})
    end
  end

  defp create_month_period(month, year) do
    with {:ok, base_date} <- Date.new(year, month, 1) do
      {:ok, base_date |> Timex.format!("{ISOdate}"), Timex.end_of_month(base_date) |> Timex.format!("{ISOdate}")}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_year_period(year) do
    with {:ok, base_date} <- Date.new(year, 1, 1) do
      {:ok, base_date |> Timex.format!("{ISOdate}"), Timex.end_of_year(base_date) |> Timex.format!("{ISOdate}")}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
