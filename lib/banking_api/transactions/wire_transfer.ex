# lib/banking_api/transactions/wire_transfer.ex

defmodule BankingApi.Transactions.WireTransfer do
  @moduledoc """
  The Banking transfer operation context
  """

  import Ecto.Query, only: [from: 2]

  alias BankingApi.Accounts.Account
  alias BankingApi.Repo
  alias Ecto.Multi

  @doc """
  Makes a wire transfer from an account to another with the specified amount
  First retrieving the accounts by their number
  Then verify if the source account has suficient balance
  Then debt the specified amount from the source account
  Then credit the specified amount on the destination account

  ## Parameters
    - source: Account number who will send the transfer
    - destination: Account number who will receive the transfer
    - amount: Total amount to be transferred

  # Returns
    - {:ok} when transfer was completed successfully
    - {:error, :balance_too_low} when transfer was blocked due a low balance

  ## Examples
    iex> Transfers.make("00001", "00002", 1000)
  """
  def make(source, destination, amount) do
    Multi.new()
    |> Multi.run(:retrieve_accounts, retrieve_accounts(source, destination))
    |> Multi.run(:verify_balances, verify_balances(amount))
    |> Multi.run(:debt_from_source, &debt_from_source/2)
    |> Multi.run(:register_debt_transaction, &register_debt_transaction/2)
    |> Multi.run(:credit_to_destination, &credit_to_destination/2)
    |> Multi.run(:register_credit_transaction, &register_credit_transaction/2)
  end

  defp retrieve_account(number) do
    query = from(acc in Account, where: acc.number == ^number, preload: [:transactions])
    case Repo.all(query) do
      [account] -> {:ok, account}
      _ -> {:error, :account_not_found}
    end
  end

  defp retrieve_accounts(source, destination) do
    fn _repo, _ ->
      with {:ok, acc_s} <- retrieve_account(source),
           {:ok, acc_d} <- retrieve_account(destination)
      do
        {:ok, {acc_s, acc_d}}
      else
        {_, _} -> {:error, :account_not_found}
      end
    end
  end

  defp verify_balances(transfer_amount) do
    fn _repo, %{retrieve_accounts: {source, destination}} ->
      if Money.compare(source.balance, transfer_amount) < 0,
        do: {:error, :balance_too_low},
        else: {:ok, {source, destination, transfer_amount}}
    end
  end

  defp debt_from_source(repo, %{verify_balances: {source, _, verified_amount}}) do
    changeset = Account.update_changeset(source, %{balance: Money.subtract(source.balance, verified_amount)})
    repo.update(changeset)
  end

  defp register_debt_transaction(repo, %{verify_balances: {source, destination, verified_amount}}) do
    changeset = Ecto.build_assoc(source, :transactions,
      %{
        amount: verified_amount,
        description: "Sent to #{destination.name} - #{destination.number}",
        operation: :debt,
        type: :transfer
      }
    )
    repo.insert(changeset)
  end

  defp credit_to_destination(repo, %{verify_balances: {_, destination, verified_amount}}) do
    changeset = Account.update_changeset(destination, %{balance: Money.add(destination.balance, verified_amount)})
    repo.update(changeset)
  end

  defp register_credit_transaction(repo, %{verify_balances: {source, destination, verified_amount}}) do
    changeset = Ecto.build_assoc(destination, :transactions,
      %{
        amount: verified_amount,
        description: "Received from #{source.name} - #{source.number}",
        operation: :credit,
        type: :transfer
      }
    )
    repo.insert(changeset)
  end
end
