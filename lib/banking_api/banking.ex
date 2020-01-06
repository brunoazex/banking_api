# lib/banking_api/banking.ex

defmodule BankingApi.Banking do
  @moduledoc """
  The Banking operations context

  Provides the banking operations

   ## Overview
    - wire_transfer/3: To make a wired transfer between two accounts
    - withdraw/2: To get a withdraw
    - get_statements/3: To get the statements in a specified period
  """

  import Ecto.Query, only: [from: 2]

  alias BankingApi.Accounts.Account
  alias BankingApi.Repo
  alias BankingApi.Transactions.Transaction
  alias BankingApi.Transactions.WireTransfer
  alias BankingApi.Transactions.Withdraw

   @doc """
  Makes a wire transfer from an account to another with the specified amount
  on an atomic database transaction

  ## Parameters
    - source: Account number who will send the transfer
    - destination: Account number who will receive the transfer
    - amount: Total amount to be transferred

  # Returns
    - {:ok} when transfer was completed successfully
    - {:error, :balance_too_low} when transfer was blocked due a low balance

  ## Examples
    iex> Banking.wire_transfer("00001", "00002", 1000)
  """
  def wire_transfer(source, destination, amount) do
    with {:amount, {:ok, requested_amount}} <- {:amount, to_money(amount)},
         {:transaction, {:ok, %{register_debt_transaction: transaction}}} <-
            {:transaction, Repo.transaction(WireTransfer.make(source, destination, requested_amount))}
    do
      {:ok, transaction}
    else
      {:amount, {:error, reason}} -> {:error, reason }
      {:transaction, {:error, reason, details, %{}}} -> {:error, reason, details}
    end
  end

  @doc """
  Makes a withdraw from an account to another with the specified amount
  on an atomic database transaction

  ## Parameters
    - source: Account number who will make the witdraw
    - amount: Total amount to be withdrawn

  # Returns
    - {:ok, transaction} when withdraw was completed successfully, where `transaction`
    represents the withdraw log
    - {:error, :verify_balances, :balance_too_low} when withdraw was blocked due a low balance

  ## Examples
    iex> Banking.withdraw("00001", 1000)
  """
  def withdraw(source, amount) do
    with {:amount, {:ok, requested_amount}} <- {:amount, to_money(amount)},
         {:transaction, {:ok, %{register_debt_transaction: transaction}}} <-
            {:transaction, Repo.transaction(Withdraw.get(source, requested_amount))}
    do
      {:ok, transaction}
    else
      {:amount, {:error, reason}} -> {:error, reason }
      {:transaction, {:error, reason, details, %{}}} -> {:error, reason, details}
    end
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
    iex> Banking.get_statements("00001", "2020-01-01", "2020-01-01")
  """
  def get_statements(account_number, from_date, to_date) do
    with  {:interval, {:ok, start_date, end_date}} <- {:interval, create_interval(from_date, to_date)},
          {:statements, statements} <- {:statements, get_statements_from_db(account_number, start_date, end_date)}
    do
      {:ok, statements }
    else
      {:interval, {:error, error_reason}} -> {:error, "interval: #{error_reason}"}
    end
  end

  @doc """
  Gets the total transactions amount for a specified period

  ## Parameters
   - from_date: A DateTime that represents the starting date of period
   - to_date: A DateTime that represents the end date of period

  ## Returns
    - {:ok, total_amount } total amount for the period
    - {:error, message} when the from/to input dates has invalid format

  ## Example
    iex> Banking.get_total_amount("2020-01-01", "2020-01-01")
  """
  def get_total_amount(from_date, to_date) do
    with  {:interval, {:ok, start_date, end_date}} <- {:interval, create_interval(from_date, to_date)},
          {:total_amount, total_amount} <- {:total_amount, get_total_amount_for_period(start_date, end_date)}
    do
      {:ok, total_amount }
    else
      {:interval, {:error, error_reason}} -> {:error, "interval: #{error_reason}"}
    end
  end

  defp get_statements_from_db(account_number, start_date, end_date) do
    statements_query =
        from(
          t in Transaction,
          join: a in Account, on: a.id == t.account_id,
          where: a.number == ^account_number and t.inserted_at >= ^start_date and t.inserted_at <= ^end_date,
          order_by: t.inserted_at
        )
     Repo.all(statements_query)
  end

  defp get_total_amount_for_period(start_date, end_date) do
    transactions_query =
        from(
          t in Transaction,
          where: t.inserted_at >= ^start_date and t.inserted_at <= ^end_date,
          order_by: t.inserted_at
        )
    Repo.all(transactions_query)
    |> Enum.reduce(Money.new(0), fn %{amount: amount}, acc -> Money.add(acc, amount) end)
  end

  defp create_interval(from_date, to_date) do
    with {:start_date, {:ok, start_date}} <- {:start_date, convert_start_date(from_date)},
         {:end_date, {:ok, end_date}} <- {:end_date, convert_end_date(to_date)}
    do
      if Date.diff(end_date, start_date) < 0 do
        {:error, "start_date can not be greater than to_date"}
      else
        {:ok, start_date, end_date}
      end
    else
      {:start_date, {:error, error_reason}} -> {:error, "from_date: #{error_reason}"}
      {:end_date, {:error, error_reason}} -> {:error, "to_date: #{error_reason}"}
    end
  end

  defp convert_start_date(value) do
    case Date.from_iso8601(value) do
      {:ok, date} ->  NaiveDateTime.new(date, ~T[00:00:00])
      {:error, reason} -> {:error, reason}
    end
  end

  def convert_end_date(value) do
    case Date.from_iso8601(value) do
      {:ok, date} ->  NaiveDateTime.new(date, ~T[23:59:59])
      {:error, reason} -> {:error, reason}
    end
  end

  defp to_money(value) do
    value
    |> amount_as_money()
    |> validate_amount()
  end

  defp amount_as_money(value) when is_bitstring(value) do
    case Money.parse(value) do
      {:ok, money} -> money
      :error -> {:error, "Invalid amount format"}
    end
  end

  defp amount_as_money(value) do
    Money.new(value)
  end

  defp validate_amount(amount) do
    if Money.zero?(amount) or !Money.positive?(amount) do
      {:error, "Invalid value"}
    else
      {:ok, amount}
    end
  end

end
