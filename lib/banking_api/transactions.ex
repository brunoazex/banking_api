defmodule BankingApi.Transactions do
  @moduledoc """
  Provides transaction reports
  """

  import Ecto.Query, only: [from: 2]

  alias BankingApi.Accounts.Account
  alias BankingApi.Repo
  alias BankingApi.Transactions.Transaction

  @doc """
  Gets the total transactions amount for a specified period

  ## Parameters
   - from_date: A DateTime that represents the starting date of period
   - to_date: A DateTime that represents the end date of period

  ## Returns
    - {:ok, total_amount } total amount for the period
    - {:error, message} when the from/to input dates has invalid format

  ## Example
    iex> Transactions.get_total_amount_from_interval("2020-01-01", "2020-01-01")
  """
  def get_total_amount_from_interval(from_date, to_date) do
    transactions_query =
        from(
          t in Transaction,
          where: t.inserted_at >= ^from_date and t.inserted_at <= ^to_date,
          order_by: t.inserted_at
        )
    transactions = Repo.all(transactions_query)
    total = transactions
            |> Enum.reduce(Money.new(0), fn %{amount: amount}, acc -> Money.add(acc, amount) end)
    {:ok, total}
  end

  @doc """
  Gets the statements for a specified period

  ## Parameters
   - account_number: A string that represents the account number with leading zeros
   - from_date: A DateTime that represents the starting date of period
   - to_date: A DateTime that represents the end date of period

  ## Returns
    - [ %Transaction{} ] a collection of transactions for the
    - {:error, message} when the from/to input dates has invalid format

  ## Example
    iex> Transactions.get_transactions_for("00001", "2020-01-01", "2020-01-01")
  """
  def get_transactions_for(account_number, from_date, to_date) do
    statements_query =
        from(
          t in Transaction,
          join: a in Account, on: a.id == t.account_id,
          where: a.number == ^account_number and t.inserted_at >= ^from_date and t.inserted_at <= ^to_date,
          order_by: t.inserted_at
        )
    {:ok, Repo.all(statements_query)}
  end

end
