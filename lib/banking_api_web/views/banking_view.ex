# lib/banking_api_web/views/banking_view.ex

defmodule BankingApiWeb.BankingView do
  use BankingApiWeb, :view

  def render("index.json", %{statements: statements, balance: balance}) do
    %{
      data: render_many(statements, BankingApiWeb.BankingView, "statement.json", as: :statement),
      balance: balance
    }
  end

  def render("statement.json", %{statement: statement}) do
    %{description: statement.description,
      amount: statement.amount,
      operation: statement.operation,
      type: statement.type}
  end
end
