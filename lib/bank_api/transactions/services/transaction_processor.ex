defmodule BankApi.Transactions.Services.TransactionProcessor do
  alias BankApi.Repo

  alias BankApi.{
    Accounts,
    Transactions.Repository,
    Transactions.Schemas.Transaction
  }

  @spec call(map()) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def call(attrs \\ %{}) do
    Repo.transact(fn ->
      with {:ok, transaction} <- Repository.create_transaction(attrs),
           {:ok, sender} <- Accounts.get_user_and_lock(transaction.sender_id),
           {:ok, receiver} <- Accounts.get_user_and_lock(transaction.receiver_id),
           {:ok, _sender} <- Accounts.debit_balance(sender, transaction.amount),
           {:ok, _receiver} <- Accounts.credit_balance(receiver, transaction.amount) do
        {:ok, transaction}
      end
    end)
  end
end
