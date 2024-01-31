defmodule BankApiWeb.V1.UserController do
  use BankApiWeb, :controller

  alias BankApi.{
    Accounts,
    Accounts.User,
    Transactions
  }

  alias BankApiWeb.V1.UserParams

  alias BankApiWeb.Auth.Guardian

  action_fallback BankApiWeb.FallbackController

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      {:ok, token, _claims} = Guardian.encode_and_sign(user)

      conn
      |> put_status(:created)
      |> render(:create, user: user, token: token)
    end
  end

  def balance(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, :balance, user: user)
  end

  def transactions(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, params} <- UserParams.validate(params) do
      transactions =
        Transactions.list_user_transactions(user.id, params[:start_date], params[:end_date])

      render(conn, :transactions, transactions: transactions)
    end
  end
end
