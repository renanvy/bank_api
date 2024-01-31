defmodule BankApi.AccountsFixtures do
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        opening_balance: 100.0,
        cpf: Faker.Phone.PtBr.phone(),
        password: "secret123",
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name()
      })
      |> BankApi.Accounts.Repository.create_user()

    user
  end
end
