defmodule BankApi.Repo.Migrations.AddUniqueIndexToEmailOnUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:cpf])
  end
end
