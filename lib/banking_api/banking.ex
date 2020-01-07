# lib/banking_api/banking.ex

defmodule BankingApi.Banking do
  @moduledoc """
  The Banking operations context

  Provides a adapter pattern for the banking operations

   ## Overview
    - wire_transfer/3: To make a wired transfer between two accounts
    - withdraw/2: To get a withdraw
    - get_statements/3: To get the statements in a specified period
  """

  alias BankingApi.Repo
  alias BankingApi.Transactions
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
   - raw_from_date: A string in Date ISO8601 format that represents the starting date of period
   - raw_to_date: A string in Date ISO8601 format represents the end date of period

  ## Returns
    - [ %Transaction{} ] a collection of transactions for the
    - {:error, message} when the from/to input dates has invalid format

  ## Example
    iex> Banking.get_statements("00001", "2020-01-01", "2020-01-01")
  """
  def get_statements(account_number, raw_from_date, raw_to_date) do
    with {:interval, {:ok, from_date, to_date}} <- {:interval, create_interval(raw_from_date, raw_to_date)},
         {:report, {:ok, transactions}} <- {:report, Transactions.get_transactions_for(account_number, from_date, to_date)}
    do
      {:ok, transactions}
    else
      {:interval, {:error, reason}} -> {:error, "interval: #{reason}"}
      {:report, {:error, reason}} -> {:error, reason}
    end
  end

  @doc """
  Gets the total transactions amount for a specified period

  ## Parameters
   - raw_from_date: A string in Date ISO8601 format that represents the starting date of period
   - raw_to_date: A string in Date ISO8601 format that represents the end date of period

  ## Returns
    - {:ok, total_amount } total amount for the period
    - {:error, message} when the from/to input dates has invalid format

  ## Example
    iex> Banking.get_total_amount("2020-01-01", "2020-01-01")
  """
  def get_total_amount(raw_from_date, raw_to_date) do
    with {:interval, {:ok, from_date, to_date}} <- {:interval, create_interval(raw_from_date, raw_to_date)},
         {:report, {:ok, total_amount}} <- {:report, Transactions.get_total_amount_from_interval(from_date, to_date)}
    do
      {:ok, total_amount}
    else
      {:interval, {:error, reason}} -> {:error, "interval: #{reason}"}
      {:report, {:error, reason}} -> {:error, reason}
    end
  end

  defp create_interval(raw_from_date, raw_to_date) do
    with {:from_date, {:ok, from_date}} <- {:from_date, build_from_date(raw_from_date)},
         {:to_date, {:ok, to_date}} <- {:to_date, build_to_date(raw_to_date)}
    do
      if Date.diff(to_date, from_date) < 0 do
        {:error, "to_date must be greater than from_date"}
      else
        {:ok, from_date, to_date}
      end
    else
      {:from_date, {:error, error_reason}} -> {:error, "from_date: #{error_reason}"}
      {:to_date, {:error, error_reason}} -> {:error, "to_date: #{error_reason}"}
    end
  end

  defp build_from_date(raw_value) do
    case Date.from_iso8601(raw_value) do
      {:ok, date} ->  NaiveDateTime.new(date, ~T[00:00:00])
      {:error, reason} -> {:error, reason}
    end
  end

  def build_to_date(raw_value) do
    case Date.from_iso8601(raw_value) do
      {:ok, date} ->  NaiveDateTime.new(date, ~T[23:59:59])
      {:error, reason} -> {:error, reason}
    end
  end

  defp to_money(value) do
    value
    |> as_money()
    |> validate_amount()
  end

  defp as_money(value) when is_bitstring(value) do
    case Money.parse(value) do
      {:ok, money} -> money
      :error -> {:error, "Invalid amount format"}
    end
  end

  defp as_money(value) do
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
