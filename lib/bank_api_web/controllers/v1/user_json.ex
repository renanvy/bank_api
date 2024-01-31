defmodule BankApiWeb.V1.UserJSON do
  def create(%{user: user, token: token}) do
    %{
      id: user.id,
      token: token
    }
  end

  def balance(%{user: user}) do
    %{balance: user.balance}
  end

  def transactions(%{transactions: transactions}) do
    Enum.map(transactions, fn transaction ->
      %{
        id: transaction.id,
        sender_id: transaction.sender_id,
        receiver_id: transaction.receiver_id,
        amount: transaction.amount,
        reverted_at: transaction.reverted_at
      }
    end)
  end
end
