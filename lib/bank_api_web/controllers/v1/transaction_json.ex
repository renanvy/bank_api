defmodule BankApiWeb.V1.TransactionJSON do
  alias BankApi.Transactions.Transaction

  def create(%{transaction: transaction}) do
    data(transaction)
  end

  def revert(%{transaction: transaction}) do
    data(transaction)
  end

  defp data(%Transaction{} = transaction) do
    %{
      id: transaction.id,
      amount: transaction.amount,
      reverted_at: transaction.reverted_at
    }
  end
end
