defmodule BankApi.Transactions.Services.TransactionProcessorTest do
  use BankApi.DataCase, async: true
  import BankApi.AccountsFixtures

  alias BankApi.Accounts.Repository, as: AccountsRepository

  alias BankApi.{
    Transactions.Services.TransactionProcessor,
    Transactions.Schemas.Transaction
  }

  describe "call/1" do
    test "with valid data process a transaction" do
      sender = user_fixture(%{opening_balance: 100.0})
      receiver = user_fixture(%{opening_balance: 0.0})
      valid_attrs = %{amount: 20.0, sender_id: sender.id, receiver_id: receiver.id}

      assert {:ok, %Transaction{} = transaction} = TransactionProcessor.call(valid_attrs)

      assert transaction.amount == Decimal.new("20.0")
      assert transaction.sender_id == sender.id
      assert transaction.receiver_id == receiver.id
      assert transaction.reverted_at == nil

      sender = AccountsRepository.get_user!(sender.id)
      receiver = AccountsRepository.get_user!(receiver.id)

      assert sender.balance == Decimal.new("80.0")
      assert receiver.balance == Decimal.new("20.0")
    end

    test "returns error when transaction data is invalid" do
      sender = user_fixture(%{opening_balance: 100.0})
      receiver = user_fixture(%{opening_balance: 0.0})
      attrs = %{amount: 0.0, sender_id: sender.id, receiver_id: receiver.id}

      assert {:error, _changeset} = TransactionProcessor.call(attrs)
    end

    test "returns an error when debit balance is failed" do
      sender = user_fixture(%{opening_balance: 20.0})
      receiver = user_fixture()
      attrs = %{amount: 30.0, sender_id: sender.id, receiver_id: receiver.id}

      assert {:error, _changeset} = TransactionProcessor.call(attrs)
    end
  end
end
