defmodule BankApi.Transactions.Schemas.TransactionTest do
  use BankApi.DataCase, async: true
  import BankApi.AccountsFixtures
  import BankApi.TransactionsFixtures

  alias BankApi.Transactions.{Schemas.Transaction, Repository}

  describe "create_changeset/2" do
    test "returns a valid changeset when data is valid" do
      sender = user_fixture(%{opening_balance: 100.0})
      receiver = user_fixture()

      assert %Ecto.Changeset{valid?: true} =
               Transaction.create_changeset(%Transaction{}, %{
                 amount: 20.0,
                 sender_id: sender.id,
                 receiver_id: receiver.id
               })
    end

    test "required fields must be present" do
      assert %Ecto.Changeset{} = changeset = Transaction.create_changeset(%Transaction{}, %{})

      assert "can't be blank" in errors_on(changeset).amount
      assert "can't be blank" in errors_on(changeset).sender_id
      assert "can't be blank" in errors_on(changeset).receiver_id
    end

    test "amount must be greater than 0" do
      assert %Ecto.Changeset{} =
               changeset =
               Transaction.create_changeset(%Transaction{}, %{
                 amount: 0.0,
                 sender_id: Ecto.UUID.generate(),
                 receiver_id: Ecto.UUID.generate()
               })

      assert "must be greater than 0" in errors_on(changeset).amount
    end

    test "sender_id must be a valid user" do
      assert %Ecto.Changeset{} =
               changeset =
               Transaction.create_changeset(%Transaction{}, %{
                 amount: 20.0,
                 sender_id: Ecto.UUID.generate(),
                 receiver_id: Ecto.UUID.generate()
               })

      {:error, changeset} = Repo.insert(changeset)

      assert "does not exist" in errors_on(changeset).sender_id
    end

    test "receiver_id must be a valid user" do
      sender = user_fixture(%{opening_balance: 100.0})

      assert %Ecto.Changeset{} =
               changeset =
               Transaction.create_changeset(%Transaction{}, %{
                 amount: 20.0,
                 sender_id: sender.id,
                 receiver_id: Ecto.UUID.generate()
               })

      {:error, changeset} = Repo.insert(changeset)

      assert "does not exist" in errors_on(changeset).receiver_id
    end

    test "sender_id and receiver_id must be different" do
      user = user_fixture()

      assert %Ecto.Changeset{} =
               changeset =
               Transaction.create_changeset(%Transaction{}, %{
                 amount: 20.0,
                 sender_id: user.id,
                 receiver_id: user.id
               })

      assert "can't be transfer to yourself" in errors_on(changeset).receiver_id
    end
  end

  describe "update_changeset/2" do
    test "returns a valid changeset when data is valid" do
      transaction = transaction_fixture(%{reverted_at: nil})

      assert %Ecto.Changeset{} =
               changeset =
               Transaction.update_changeset(transaction, %{reverted_at: DateTime.utc_now()})

      assert changeset.valid?
      assert changeset.changes.reverted_at
    end

    test "returns a changeset error when transaction already has reverted" do
      transaction = transaction_fixture()

      {:ok, %Transaction{} = transaction} =
        Repository.update_transaction(transaction, %{reverted_at: ~U[2020-01-01 10:00:00Z]})

      assert %Ecto.Changeset{} =
               changeset =
               Transaction.update_changeset(transaction, %{
                 reverted_at: DateTime.utc_now()
               })

      assert "transaction already reverted" in errors_on(changeset).reverted_at
    end
  end
end
