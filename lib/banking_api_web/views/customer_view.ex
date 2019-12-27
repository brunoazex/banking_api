defmodule BankingApiWeb.CustomerView do
  use BankingApiWeb, :view
  alias BankingApiWeb.CustomerView

  def render("index.json", %{customer: customer}) do
    %{data: render_many(customer, CustomerView, "customer.json")}
  end

  def render("show.json", %{customer: customer}) do
    %{data: render_one(customer, CustomerView, "customer.json")}
  end

  def render("customer.json", %{customer: customer}) do
    %{id: customer.id,
      name: customer.name,
      email: customer.email,
      document: customer.document}
  end
end
