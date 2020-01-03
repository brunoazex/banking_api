defmodule BankingApi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :description, :string
      add :amount, :integer
      add :operation, :string, size: 8
      add :type, :string, size: 8
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end
    create index(:transactions, [:account_id])
  end
end
