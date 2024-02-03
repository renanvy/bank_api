defmodule BankApi.Transactions do
  alias BankApi.{
    Transactions.Repository,
    Transactions.Services.TransactionProcessor,
    Transactions.Services.TransactionReverser
  }

  defdelegate list_user_transactions(user_id, start_date, end_date), to: Repository
  defdelegate get_user_transaction(transaction_id, user_id), to: Repository
  defdelegate process_transaction(attrs), to: TransactionProcessor, as: :call
  defdelegate revert_transaction(transaction), to: TransactionReverser, as: :call
end
