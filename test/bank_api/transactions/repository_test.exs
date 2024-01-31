defmodule BankApi.Transactions.RepositoryTest do
  use BankApi.DataCase, async: true
  import BankApi.AccountsFixtures
  import BankApi.TransactionsFixtures

  alias BankApi.{Transactions.Repository, Transactions.Transaction}

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

    test "validates required fields" do
      assert {:error, changeset} = Repository.create_transaction(%{})

      assert "can't be blank" in errors_on(changeset).amount
      assert "can't be blank" in errors_on(changeset).sender_id
      assert "can't be blank" in errors_on(changeset).receiver_id
    end

    test "validates amount is greater than 0" do
      sender = user_fixture(%{opening_balance: 100.0})
      receiver = user_fixture(%{opening_balance: 0.0})

      assert {:error, changeset} =
               Repository.create_transaction(%{
                 amount: 0.0,
                 sender_id: sender.id,
                 receiver_id: receiver.id
               })

      assert "must be greater than 0" in errors_on(changeset).amount
    end

    test "validates sender_id is a valid user" do
      receiver = user_fixture(%{opening_balance: 0.0})

      assert {:error, changeset} =
               Repository.create_transaction(%{
                 amount: 20.0,
                 sender_id: Ecto.UUID.generate(),
                 receiver_id: receiver.id
               })

      assert "does not exist" in errors_on(changeset).sender_id
    end

    test "validates receiver_id is a valid user" do
      sender = user_fixture(%{opening_balance: 100.0})

      assert {:error, changeset} =
               Repository.create_transaction(%{
                 amount: 20.0,
                 sender_id: sender.id,
                 receiver_id: Ecto.UUID.generate()
               })

      assert "does not exist" in errors_on(changeset).receiver_id
    end

    test "validates sender_id and receiver_id are different" do
      user = user_fixture()

      assert {:error, changeset} =
               Repository.create_transaction(%{
                 amount: 20.0,
                 sender_id: user.id,
                 receiver_id: user.id
               })

      assert "can't be transfer to yourself" in errors_on(changeset).receiver_id
    end
  end

  describe "update_transaction/2" do
    test "with valid data update a transaction" do
      transaction = transaction_fixture(%{reverted_at: nil})

      assert {:ok, %Transaction{} = transaction} =
               Repository.update_transaction(transaction, %{reverted_at: ~U[2020-01-01 10:00:00Z]})

      assert transaction.reverted_at == ~U[2020-01-01 10:00:00Z]
    end

    test "returns a changeset error when transaction already has reverted" do
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
