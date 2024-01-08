defmodule BankApiWeb.V1.SessionController do
  use BankApiWeb, :controller

  action_fallback BankApiWeb.FallbackController

  alias BankApi.{Accounts, Accounts.Guardian}

  def create(conn, %{"cpf" => cpf, "password" => password}) do
    case Accounts.authenticate_user(cpf, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        conn
        |> put_status(:ok)
        |> render(:user_token, user: user, token: token)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_status(:ok)
    |> json(%{msg: "Logged out"})
  end
end
