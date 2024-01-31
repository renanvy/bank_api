defmodule BankApiWeb.V1.SessionController do
  use BankApiWeb, :controller

  action_fallback BankApiWeb.FallbackController

  alias BankApi.Accounts
  alias BankApiWeb.V1.SessionParams
  alias BankApiWeb.Auth.Guardian

  def create(conn, params) do
    with {:ok, params} <- SessionParams.validate(params),
         {:ok, user} <- Accounts.authenticate_user(params[:cpf], params[:password]) do
      {:ok, token, _claims} = Guardian.encode_and_sign(user)

      conn
      |> put_status(:ok)
      |> render(:user_token, user: user, token: token)
    end
  end
end
