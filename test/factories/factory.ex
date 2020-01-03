# test/factories/factory.ex

defmodule BankingApi.Test.Factories.Factory do
  @moduledoc """
  Provides Factories for tests
  """
  use BankingApi.EctoWithChangesetStrategy, repo: BankingApi.Repo, strict: false

  def account_factory(attrs) do

    account = %BankingApi.Accounts.Account{
      name: "Normal user",
      email: "normal@user.com",
      document: "000.000.000-01",
      password: "12345678"
    }

    Map.merge(account, attrs)
  end
end
