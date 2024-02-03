defmodule BankApi.Accounts.RepositoryTest do
  use BankApi.DataCase, async: true
  import BankApi.AccountsFixtures

  alias BankApi.{Accounts.Repository, Accounts.Schemas.User}

  describe "get_user!/1" do
    test "returns the user with given id" do
      user = user_fixture()
      assert Repository.get_user!(user.id).id == user.id
    end
  end

  describe "get_user_and_lock/1" do
    test "returns the user with given id and lock record in database" do
      user = user_fixture()
      user_id = user.id
      assert {:ok, %User{id: ^user_id}} = Repository.get_user_and_lock(user.id)
    end

    test "returns not found when user doesn't exist" do
      assert {:error, :user_not_found} = Repository.get_user_and_lock(Ecto.UUID.generate())
    end
  end

  describe "create_user/1" do
    test "with valid data creates a user" do
      valid_attrs = %{
        opening_balance: 120.5,
        first_name: "John",
        last_name: "Doe",
        cpf: "34312343433",
        password: "12345678"
      }

      assert {:ok, %User{} = user} = Repository.create_user(valid_attrs)
      assert user.opening_balance == Decimal.new("120.5")
      assert user.balance == Decimal.new("120.5")
      assert user.first_name == "John"
      assert user.last_name == "Doe"
      assert user.cpf == "34312343433"
    end

    test "returns an error when attrs is invalid" do
      assert {:error, %Ecto.Changeset{}} =
               Repository.create_user(%{
                 opening_balance: nil,
                 first_name: nil,
                 last_name: nil,
                 cpf: nil,
                 password: nil
               })
    end
  end

  describe "update_balance/2" do
    test "with valid data updates user balance" do
      user = user_fixture(%{balance: Decimal.new("50.0")})
      assert {:ok, %User{} = user} = Repository.update_balance(user, 100)
      assert user.balance == Decimal.new("100.0")
    end
  end

  describe "debit_balance/2" do
    test "with valid data debits user balance" do
      sender = user_fixture(%{balance: Decimal.new("100.0")})

      assert {:ok, %User{} = sender} = Repository.debit_balance(sender, Decimal.new("50.0"))
      assert sender.balance == Decimal.new("50.0")
    end

    test "with invalid data returns error changeset" do
      sender = user_fixture(%{balance: Decimal.new("100.0")})

      assert {:error, %Ecto.Changeset{}} = Repository.debit_balance(sender, Decimal.new("150.0"))
    end
  end

  describe "credit_balance/2" do
    test "with valid data credits user balance" do
      receiver = user_fixture(%{balance: Decimal.new("100.0")})

      assert {:ok, %User{} = receiver} = Repository.credit_balance(receiver, Decimal.new("50.0"))
      assert receiver.balance == Decimal.new("150.0")
    end

    test "with invalid data returns error changeset" do
      receiver = user_fixture(%{balance: Decimal.new("100.0")})

      assert {:error, %Ecto.Changeset{}} =
               Repository.credit_balance(receiver, Decimal.new("-200.0"))
    end
  end
end
