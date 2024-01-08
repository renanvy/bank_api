defmodule BankApiWeb.V1.TransactionController do
  use BankApiWeb, :controller

  alias BankApi.Transactions
  alias BankApi.Transactions.Transaction

  action_fallback BankApiWeb.FallbackController

  def create(conn, transaction_params) do
    with {:ok, %Transaction{} = transaction} <-
           Transactions.create_transaction(transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/transactions/#{transaction}")
      |> render(:show, transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    render(conn, :show, transaction: transaction)
  end
end
