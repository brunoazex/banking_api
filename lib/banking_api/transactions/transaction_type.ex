# lib/banking_api/transactions/transaction_type.ex

defmodule BankingApi.Transactions.TransactionType do
  @moduledoc """
  Transaction operation enumerator
  """
  use Exnumerator, values: [:withdraw, :transfer, :deposit]

end
