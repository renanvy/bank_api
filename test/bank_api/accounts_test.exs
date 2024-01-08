defmodule BankApi.AccountsTest do
  use BankApi.DataCase

  alias BankApi.Accounts

  describe "users" do
    alias BankApi.Accounts.User

    import BankApi.AccountsFixtures

    @invalid_attrs %{balance: nil, first_name: nil, last_name: nil, cpf: nil}

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        opening_balance: "120.5",
        balance: "120.5",
        first_name: "some first_name",
        last_name: "some last_name",
        cpf: "some cpf"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.opening_balance == Decimal.new("120.5")
      assert user.balance == Decimal.new("120.5")
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.cpf == "some cpf"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        balance: "456.7",
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        cpf: "some updated cpf"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.opening_balance == Decimal.new("120.5")
      assert user.balance == Decimal.new("456.7")
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.cpf == "some updated cpf"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
