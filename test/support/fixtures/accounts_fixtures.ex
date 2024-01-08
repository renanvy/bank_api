defmodule BankApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BankApi.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        opening_balance: "120.5",
        balance: "120.5",
        cpf: "some cpf",
        first_name: "some first_name",
        last_name: "some last_name"
      })
      |> BankApi.Accounts.create_user()

    user
  end
end
