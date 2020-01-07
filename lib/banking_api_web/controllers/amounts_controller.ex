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

  def create_month_period(month, year) do
    with {:month, {month_int, _}} <- {:month, Integer.parse(month)},
         {:year, {year_int, _}} <- {:year, Integer.parse(year)},
         {:ok, base_date} <- Date.new(year_int, month_int, 1) do
      start_date = Timex.format!(base_date, "{ISOdate}")
      end_date = base_date
                 |> Timex.end_of_month()
                 |> Timex.format!("{ISOdate}")
      {:ok, start_date, end_date }
    else
      {:month, :error} -> {:error, "Month: invalid value"}
      {:year, :error} -> {:error, "Year: invalid value"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_year_period(year) do
    with {:year, {year_int, _}} <- {:year, Integer.parse(year)},
         {:ok, base_date} <- Date.new(year_int, 1, 1) do
      start_date = Timex.format!(base_date, "{ISOdate}")
      end_date = base_date
                 |> Timex.end_of_year()
                 |> Timex.format!("{ISOdate}")
      {:ok, start_date, end_date }
    else
      {:year, :error} -> {:error, "Year: invalid value"}
      {:error, reason} -> {:error, reason}
    end
  end
end
