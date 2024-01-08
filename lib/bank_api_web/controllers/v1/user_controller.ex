defmodule BankApiWeb.V1.UserController do
  use BankApiWeb, :controller

  alias BankApi.Accounts
  alias BankApi.Accounts.Guardian
  alias BankApi.Accounts.User

  action_fallback BankApiWeb.FallbackController

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      {:ok, token, _claims} = Guardian.encode_and_sign(user)

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/users/#{user}")
      |> render(:create, user: user, token: token)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end
end
