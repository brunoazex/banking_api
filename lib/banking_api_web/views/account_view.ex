# lib/banking_api_web/views/account_view.ex

defmodule BankingApiWeb.AccountView do
  use BankingApiWeb, :view

   def render("account.json", %{account: account, token: token}) do
    %{customer: account.name,
      account: account.number,
      token: token
    }
  end
end
