# lib/baking_api/transactions/transaction.ex

defmodule BankingApi.Transactions.Transaction do
  use Ecto.Schema
  @moduledoc """
  Account's transaction log entity
  """
  import Ecto.Changeset

  schema "transactions" do
    field :amount, Money.Ecto.Amount.Type
    field :description, :string
    field :operation, BankingApi.Transactions.OperationType
    field :type, BankingApi.Transactions.TransactionType
    belongs_to :account, BankingApi.Accounts.Account, foreign_key: :account_id
    timestamps()
  end

   @doc false
   def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:account_id, :description, :operation, :amount])
    |> validate_required([:description])
    |> validate_required([:operation])
    |> validate_required([:amount])
    |> assoc_constraint(:account)
  end

end
