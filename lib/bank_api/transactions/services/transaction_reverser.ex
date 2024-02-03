defmodule BankApi.Transactions.Services.TransactionReverser do
  alias BankApi.Repo

  alias BankApi.{
    Accounts,
    Transactions.Repository,
    Transactions.Schemas.Transaction
  }

  @spec call(Transaction.t()) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def call(transaction) do
    Repo.transact(fn ->
      with {:ok, transaction} <- revert_transaction(transaction),
           {:ok, sender} <- Accounts.get_user_and_lock(transaction.sender_id),
           {:ok, receiver} <- Accounts.get_user_and_lock(transaction.receiver_id),
           {:ok, _sender} <- Accounts.credit_balance(sender, transaction.amount),
           {:ok, _receiver} <- Accounts.debit_balance(receiver, transaction.amount) do
        {:ok, transaction}
      end
    end)
  end

  defp revert_transaction(transaction) do
    Repository.update_transaction(transaction, %{reverted_at: DateTime.utc_now()})
  end
end
