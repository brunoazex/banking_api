# lib/banking_api/accounts/account.ex

defmodule BankingApi.Accounts.Account do
  use Ecto.Schema
  @moduledoc """
  Account entity
  """

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias BankingApi.Accounts.Account
  alias BankingApi.Repo

  schema "accounts" do
    field :name, :string
    field :email, :string
    field :document, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :number, :string
    field :balance, :integer
    has_many :transactions, BankingApi.Transactions.Transaction, foreign_key: :account_id
    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :document, :email, :password])
    |> common_changeset()
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> put_hashed_password()
    |> put_account_number()
    |> put_signup_bonus()
  end

  def update_changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :document, :email, :balance])
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_required([:email])
    |> validate_required([:document])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
  end

  defp put_signup_bonus(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        changeset
        |> put_change(:balance, 1000)
        |> put_assoc(:transactions, [%{description: "Signup bonus", amount: 1000, operation: :credit, type: :deposit}])
      _ ->
        changeset
    end
  end

  defp put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
      _ ->
        changeset
    end
  end

  defp put_account_number(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        put_change(changeset, :number, generate_account_number())
      _ ->
        changeset
    end
  end

  defp generate_account_number do
    get_next_account_number()
    |> Integer.to_string
    |> String.pad_leading(5, "0")
  end

  defp get_next_account_number do
    query = from a in Account, select: max(a.id)
    value = Repo.one(query) || 0
    value + 1
  end
end
