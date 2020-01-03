# lib/banking_api/transactions/withdraw.ex

defmodule BankingApi.Transactions.Withdraw do
  @moduledoc """
  The Banking transfer operation context
  """

  import Ecto.Query, only: [from: 2]

  alias BankingApi.Accounts.Account
  alias BankingApi.Repo
  alias Ecto.Multi

  @doc """
  Makes a withdraw from an account to another with the specified amount
  First retrieving the account by it's number
  Then verify if account has suficient balance
  Then debt the specified amount from the source account

  ## Parameters
    - source: Account number who will make the witdraw
    - amount: Total amount to be withdrawn

  # Returns
    - {:ok} when withdraw was completed successfully
    - {:error, :balance_too_low} when withdraw was blocked due a low balance

  ## Examples
    iex> Withdraw.make("00001", 1000)
  """
  def get(source, amount) do
    Multi.new()
    |> Multi.run(:retrieve_account, retrieve_account(source))
    |> Multi.run(:verify_balance, verify_balance(amount))
    |> Multi.run(:debt_from_source, &debt_from_source/2)
    |> Multi.run(:register_debt_transaction, &register_debt_transaction/2)
  end

  defp retrieve_account(source) do
    fn _repo, _ ->
      query = from(acc in Account, where: acc.number == ^source, preload: [:transactions])
      case Repo.all(query) do
        [acc] -> {:ok, {acc}}
        _ -> {:error, :account_not_found}
      end
    end
  end

  defp verify_balance(transfer_amount) do
    fn _repo, %{retrieve_account: {source}} ->
      if source.balance < transfer_amount,
        do: {:error, :balance_too_low},
        else: {:ok, {source, transfer_amount}}
    end
  end

  defp debt_from_source(repo, %{verify_balance: {source, verified_amount}}) do
    changeset = Account.update_changeset(source, %{balance: source.balance - verified_amount})
    repo.update(changeset)
  end

  defp register_debt_transaction(repo, %{verify_balance: {source, verified_amount}}) do
    changeset = Ecto.build_assoc(source, :transactions,
      %{
        amount: verified_amount,
        description: "Withdraw",
        operation: :debt,
        type: :withdraw
      }
    )
    repo.insert(changeset)
  end
end
