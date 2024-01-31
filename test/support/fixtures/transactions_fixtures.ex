defmodule BankApi.TransactionsFixtures do
  import BankApi.AccountsFixtures

  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        sender_id: user_fixture().id,
        receiver_id: user_fixture().id,
        amount: 100.0
      })
      |> BankApi.Transactions.Repository.create_transaction()

    transaction
  end
end
