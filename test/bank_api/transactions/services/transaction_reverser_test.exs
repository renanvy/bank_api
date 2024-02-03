defmodule BankApi.Transactions.Services.TransactionReverserTest do
  use BankApi.DataCase, async: true
  import BankApi.AccountsFixtures
  import BankApi.TransactionsFixtures

  alias BankApi.Accounts.Repository, as: AccountsRepository

  alias BankApi.{
    Transactions.Repository,
    Transactions.Services.TransactionReverser,
    Transactions.Services.TransactionProcessor,
    Transactions.Schemas.Transaction
  }

  describe "call/1" do
    test "with valid data revert a transaction" do
      sender = user_fixture(%{opening_balance: 100.0})
      receiver = user_fixture(%{opening_balance: 0.0})

      {:ok, transaction} =
        TransactionProcessor.call(%{amount: 20.0, sender_id: sender.id, receiver_id: receiver.id})

      assert {:ok, %Transaction{} = reverted_transaction} = TransactionReverser.call(transaction)

      assert reverted_transaction.reverted_at != nil

      sender = AccountsRepository.get_user!(sender.id)
      receiver = AccountsRepository.get_user!(receiver.id)

      assert sender.balance == Decimal.new("100.0")
      assert receiver.balance == Decimal.new("0.0")
    end

    test "returns an error when reverse failed" do
      transaction = transaction_fixture()

      {:ok, transaction} =
        Repository.update_transaction(transaction, %{reverted_at: ~U[2021-01-01 00:00:00Z]})

      assert {:error, %Ecto.Changeset{} = changeset} = TransactionReverser.call(transaction)

      assert "transaction already reverted" in errors_on(changeset).reverted_at
    end

    test "returns an error when debit balance is failed" do
      john = user_fixture(%{opening_balance: 20.0})
      mary = user_fixture(%{opening_balance: 0.0})
      tommy = user_fixture(%{opening_balance: 0.0})

      {:ok, transaction_1} =
        TransactionProcessor.call(%{amount: 20.0, sender_id: john.id, receiver_id: mary.id})

      {:ok, _transaction_2} =
        TransactionProcessor.call(%{amount: 20.0, sender_id: mary.id, receiver_id: tommy.id})

      assert {:error, %Ecto.Changeset{} = changeset} = TransactionReverser.call(transaction_1)

      assert "insuficient balance" in errors_on(changeset).balance
    end
  end
end
