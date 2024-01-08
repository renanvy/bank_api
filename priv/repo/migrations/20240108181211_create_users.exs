defmodule BankApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :cpf, :string, null: false
      add :opening_balance, :decimal, null: false, default: 0.0
      add :balance, :decimal, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
