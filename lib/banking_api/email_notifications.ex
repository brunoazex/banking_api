defmodule BankingApi.EmailNotifications do
  @moduledoc """
  Email notification templates
  """

  import Bamboo.Email

  @doc false
  def withdraw(account, amount) do
    new_email(
      to: account.email,
      from: "notreply@bankingapi.com",
      subject: "A Withdraw just happened in your account!",
      html_body: "<strong>Account: #{account.number}</strong><br><strong>Amount: #{Money.to_string(amount)}</strong>",
      text_body: "Account: #{account.number}, Amount: #{Money.to_string(amount)}"
    )
  end
end
