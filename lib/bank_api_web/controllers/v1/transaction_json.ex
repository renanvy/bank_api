defmodule BankApiWeb.V1.TransactionJSON do
  alias BankApi.Transactions.Transaction

  @doc """
  Renders a single transaction.
  """
  def show(%{transaction: transaction}) do
    %{data: data(transaction)}
  end

  defp data(%Transaction{} = transaction) do
    %{
      id: transaction.id,
      amount: transaction.amount,
      reverted_at: transaction.reverted_at
    }
  end
end
