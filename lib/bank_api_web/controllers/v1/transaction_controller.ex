defmodule BankApiWeb.V1.TransactionController do
  use BankApiWeb, :controller

  alias BankApi.Transactions
  alias BankApi.Transactions.Transaction

  action_fallback BankApiWeb.FallbackController

  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    params = Map.put(params, "sender_id", user.id)

    with {:ok, %Transaction{} = transaction} <- Transactions.process_transaction(params) do
      conn
      |> put_status(:created)
      |> render(:create, transaction: transaction)
    end
  end

  def revert(conn, %{"transaction_id" => transaction_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, transaction} <- Transactions.get_user_transaction(transaction_id, user.id),
         {:ok, transaction} <- Transactions.revert_transaction(transaction) do
      conn
      |> put_status(:ok)
      |> render(:revert, transaction: transaction)
    end
  end
end
