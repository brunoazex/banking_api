defmodule BankingApi.Accounts.Account do
  use Ecto.Schema
  @moduledoc """
  Account entity
  """
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias BankingApi.Accounts.Account
  alias BankingApi.Repo

  schema "account" do
    field :name, :string
    field :email, :string
    field :document, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :number, :string
    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :document, :email, :password])
    |> validate_required([:name])
    |> validate_required([:email])
    |> validate_required([:document])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> validate_required([:document])
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> put_hashed_password()
  end

  def create_changeset(account, attrs) do
    account
    |> changeset(attrs)
    |> put_account_number()
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
    with value <- (from a in Account, select: coalesce(max(a.id), 0)) |> Repo.one() do
      value + 1
    end
  end
end
