defmodule BankingApi.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:account) do
      add :name, :string
      add :email, :string
      add :document, :string
      add :password_hash, :string
      add :number, :string

      timestamps()
    end

    create unique_index(:account, [:number])
    create unique_index(:account, [:name])
    create unique_index(:account, [:email])
    create unique_index(:account, [:document])
  end
end
