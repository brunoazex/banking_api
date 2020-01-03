# lib/banking_api/accounts.ex

defmodule BankingApi.Accounts do
  @moduledoc """
  The Accounts context

  Provides Account's repository operations

  ## Overview
    - signup/1: To create new accounts on supplied data
    - get_by_id/1: To retrieve an account by it's `id`
    - get_by_number/1: To retrieve an account by it's `number`
  """
  import Ecto.Query, warn: false

  alias BankingApi.Accounts.Account
  alias BankingApi.Repo

  @doc """
  Tries to signup for a new account

  ## Parameters
   - signup_attrs: A struct that represents required values to complete the signup process

  ## Returns
    - {:ok, account} when signup is accepted, where `account` is the new signed up account
    - {:error, reason} when signup is not accepted, where `reason` is the reason of not acceptance

  ## Example
    iex> signup_attrs = %{name: "Normal user", email: "normal@user.com", document: "000.000.000-01", password: "12345678"}
    iex> Accounts.signup(signup_attrs)

  """
  def signup(signup_attrs) do
    %Account{}
    |> Account.changeset(signup_attrs)
    |> Repo.insert()
  end

  @doc """
  Tries to get an account by the specified `id`

  ## Parameters
   - id: A integer that represents the id of the account

  ## Returns
    - {:ok, account} when a account matches the specified `id`, where `account` is the retrieved account
    - {:error, :not_found} when no account matches the specified `id`

  ## Example
    iex> Accounts.get_by_id(1)

  """
  def get_by_id(id) do
   case Account
    |> Repo.get(id)
    |> Repo.preload([:transactions])
    do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  @doc """
  Tries to get an account by the specified account `number`

  ## Parameters
   - number: A string that represents the account number with leading zeros

  ## Returns
    - {:ok, account} when a account matches the specified `number`, where `account` is the retrieved account
    - {:error, :not_found} when no account matches the specified `number`

  ## Example
    iex> Accounts.get_by_number("00001")
  """
  def get_by_number(number) do
    case Account |> Repo.get_by(number: number) |> Repo.preload([:transactions]) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

end
