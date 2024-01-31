defmodule BankApi.Transactions do
  alias BankApi.{
    Transactions.Repository,
    Transactions.Services.TransactionProcessor,
    Transactions.Services.TransactionReverser
  }

  defdelegate list_user_transactions(user_id, start_date, end_date), to: Repository
  defdelegate get_user_transaction(transaction_id, user_id), to: Repository
  def process_transaction(attrs), do: TransactionProcessor.call(attrs)
  def revert_transaction(transaction), do: TransactionReverser.call(transaction)
end
