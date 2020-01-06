# lib/banking_api_web/views/backoffice_view.ex

defmodule BankingApiWeb.AmountsView do
  use BankingApiWeb, :view

  def render("index.json", %{start_date: start_date, end_date: end_date, total_amount: total_amount}) do
    %{start_date: start_date,
      end_date: end_date,
      total_amount: Money.to_string(total_amount, symbol: false)
    }
  end
end
