defmodule BankApi.Accounts.Services.AuthenticatorTest do
  use BankApi.DataCase, async: true
  import BankApi.AccountsFixtures

  alias BankApi.Accounts.Services.Authenticator

  describe "call/2" do
    test "with valid credentials authenticate user" do
      user = user_fixture()
      {:ok, result} = Authenticator.call(user.cpf, "secret123")
      assert result.id == user.id
    end

    test "with invalid credentials returns an error" do
      user = user_fixture()

      assert {:error, :invalid_credentials} = Authenticator.call(user.cpf, "invalid_password")

      assert {:error, :invalid_credentials} = Authenticator.call("12343234322", "secret123")
    end
  end
end
