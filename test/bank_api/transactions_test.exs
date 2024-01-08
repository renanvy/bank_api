defmodule BankApi.TransactionsTest do
  use BankApi.DataCase

  alias BankApi.Transactions

  describe "transactions" do
    alias BankApi.Transactions.Transaction

    import BankApi.TransactionsFixtures

    @invalid_attrs %{amount: nil, reverted_at: nil}

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{amount: "120.5", reverted_at: ~U[2024-01-07 20:01:00Z]}

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.reverted_at == ~U[2024-01-07 20:01:00Z]
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end
  end
end
