defmodule BankApi.Transactions.RepositoryTest do
  use BankApi.DataCase, async: true
  import BankApi.AccountsFixtures
  import BankApi.TransactionsFixtures

  alias BankApi.{Transactions.Repository, Transactions.Schemas.Transaction}

  describe "list_user_transactions/3" do
    test "returns a list from user transactions filtered by date" do
      user_1 = user_fixture()
      user_2 = user_fixture()

      transaction_1 =
        transaction_fixture(%{sender_id: user_1.id, inserted_at: ~U[2020-01-01 10:00:00Z]})

      transaction_2 =
        transaction_fixture(%{receiver_id: user_1.id, inserted_at: ~U[2020-01-10 23:00:00Z]})

      transaction_3 =
        transaction_fixture(%{sender_id: user_2.id, inserted_at: ~U[2020-01-01 10:00:00Z]})

      transaction_4 =
        transaction_fixture(%{receiver_id: user_2.id, inserted_at: ~U[2020-01-10 23:00:00Z]})

      assert Repository.list_user_transactions(user_1.id, ~D[2020-01-01], ~D[2020-01-10]) == [
               transaction_1,
               transaction_2
             ]

      assert Repository.list_user_transactions(user_2.id, ~D[2020-01-01], ~D[2020-01-10]) == [
               transaction_3,
               transaction_4
             ]
    end
  end

  describe "get_user_transaction/2" do
    test "returns the user transaction" do
      user = user_fixture()
      transaction = transaction_fixture(%{sender_id: user.id})
      transaction_id = transaction.id

      assert {:ok, %Transaction{id: ^transaction_id}} =
               Repository.get_user_transaction(transaction.id, user.id)
    end

    test "returns not found when transaction belongs to another user" do
      user = user_fixture()
      transaction = transaction_fixture()

      assert {:error, :not_found} = Repository.get_user_transaction(transaction.id, user.id)
    end
  end

  describe "create_transaction/1" do
    test "with valid data creates a transaction" do
      sender = user_fixture(%{opening_balance: 100.0})
      receiver = user_fixture(%{opening_balance: 0.0})
      valid_attrs = %{amount: 20.0, sender_id: sender.id, receiver_id: receiver.id}

      assert {:ok, %Transaction{} = transaction} = Repository.create_transaction(valid_attrs)
      assert transaction.amount == Decimal.new("20.0")
      assert transaction.sender_id == sender.id
      assert transaction.receiver_id == receiver.id
      assert transaction.reverted_at == nil
    end

    test "with invalid data doesn't create a transaction" do
      assert {:error, %Ecto.Changeset{}} = Repository.create_transaction(%{})
    end
  end

  describe "update_transaction/2" do
    test "with valid data update a transaction" do
      transaction = transaction_fixture(%{reverted_at: nil})

      assert {:ok, %Transaction{} = transaction} =
               Repository.update_transaction(transaction, %{reverted_at: ~U[2020-01-01 10:00:00Z]})

      assert transaction.reverted_at == ~U[2020-01-01 10:00:00Z]
    end

    test "returns an error when transaction update failed" do
      transaction = transaction_fixture()

      {:ok, %Transaction{} = transaction} =
        Repository.update_transaction(transaction, %{reverted_at: ~U[2020-01-01 10:00:00Z]})

      assert {:error, changeset} =
               Repository.update_transaction(transaction, %{
                 reverted_at: ~U[2020-01-02 10:00:00Z]
               })

      assert "transaction already reverted" in errors_on(changeset).reverted_at
    end
  end
end
