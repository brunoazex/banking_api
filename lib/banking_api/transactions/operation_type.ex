# lib/banking_api/transactions/operation_type.ex

defmodule BankingApi.Transactions.OperationType do
  @moduledoc """
  Transaction operation enumerator
  """
  use Exnumerator, values: [:credit, :debt]

end
