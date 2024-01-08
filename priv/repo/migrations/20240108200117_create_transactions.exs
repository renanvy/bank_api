defmodule BankApi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :decimal, null: false
      add :reverted_at, :utc_datetime, null: true
      add :sender_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :receiver_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:sender_id])
    create index(:transactions, [:receiver_id])
  end
end
