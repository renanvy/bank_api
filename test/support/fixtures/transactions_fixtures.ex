defmodule BankApi.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BankApi.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        reverted_at: ~U[2024-01-07 20:01:00Z]
      })
      |> BankApi.Transactions.create_transaction()

    transaction
  end
end
