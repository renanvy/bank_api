defmodule BankApi.Accounts.Schemas.UserTest do
  use BankApi.DataCase, async: true
  import BankApi.AccountsFixtures

  alias BankApi.Accounts.Schemas.User

  describe "create_changeset/2" do
    test "returns a valid changeset with when data is valid" do
      valid_attrs = %{
        opening_balance: 120.5,
        first_name: "John",
        last_name: "Doe",
        cpf: "34312343433",
        password: "12345678"
      }

      assert %Ecto.Changeset{valid?: true} = User.create_changeset(%User{}, valid_attrs)
    end

    test "validates required fields" do
      assert %Ecto.Changeset{} =
               changeset =
               User.create_changeset(%User{}, %{
                 opening_balance: nil,
                 first_name: nil,
                 last_name: nil,
                 cpf: nil,
                 password: nil
               })

      assert "can't be blank" in errors_on(changeset).opening_balance
      assert "can't be blank" in errors_on(changeset).first_name
      assert "can't be blank" in errors_on(changeset).last_name
      assert "can't be blank" in errors_on(changeset).cpf
      assert "can't be blank" in errors_on(changeset).password
    end

    test "validates opening_balance is greater than or equal to 0.0" do
      assert %Ecto.Changeset{} =
               changeset =
               User.create_changeset(%User{}, %{
                 opening_balance: -1.0,
                 first_name: "John",
                 last_name: "Doe",
                 cpf: "34312343433",
                 password: "12345678"
               })

      assert "must be greater than or equal to 0.0" in errors_on(changeset).opening_balance
    end

    test "validates cpf is unique" do
      user = user_fixture()

      %Ecto.Changeset{} =
        changeset =
        User.create_changeset(%User{}, %{
          opening_balance: 120.5,
          first_name: "John",
          last_name: "Doe",
          cpf: user.cpf,
          password: "12345678"
        })

      {:error, changeset} = Repo.insert(changeset)

      assert "has already been taken" in errors_on(changeset).cpf
    end

    test "generates a password hash" do
      assert %Ecto.Changeset{} =
               changeset =
               User.create_changeset(%User{}, %{
                 opening_balance: 120.5,
                 first_name: "John",
                 last_name: "Doe",
                 cpf: "34312343433",
                 password: "12345678"
               })

      assert changeset.changes.password_hash
    end

    test "sets balance to opening_balance" do
      assert %Ecto.Changeset{} =
               changeset =
               User.create_changeset(%User{}, %{
                 opening_balance: 120.5,
                 first_name: "John",
                 last_name: "Doe",
                 cpf: "34312343433",
                 password: "12345678"
               })

      assert changeset.changes.balance == changeset.changes.opening_balance
    end
  end

  describe "update_balance_changeset" do
    test "returns a valid changeset when attrs is valid" do
      user = user_fixture()
      assert %Ecto.Changeset{valid?: true} = User.update_balance_changeset(user, %{balance: 100})
    end

    test "validates required fields" do
      user = user_fixture()
      assert %Ecto.Changeset{} = changeset = User.update_balance_changeset(user, %{balance: nil})
      assert "can't be blank" in errors_on(changeset).balance
    end

    test "validates insuficient balance" do
      user = user_fixture()
      assert %Ecto.Changeset{} = changeset = User.update_balance_changeset(user, %{balance: -100})
      assert "insuficient balance" in errors_on(changeset).balance
    end
  end
end
