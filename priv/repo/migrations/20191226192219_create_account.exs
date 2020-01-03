defmodule BankingApi.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string
      add :email, :string
      add :document, :string
      add :password_hash, :string
      add :number, :string
      add :balance, :integer

      timestamps()
    end
  end
end
