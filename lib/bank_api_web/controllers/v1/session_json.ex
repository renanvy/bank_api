defmodule BankApiWeb.V1.SessionJSON do
  alias BankApi.Accounts.User

  @doc """
  Renders a user and token.
  """
  def user_token(%{user: user, token: token}) do
    %{data: data(user, token)}
  end

  defp data(%User{} = user, token) do
    %{
      id: user.id,
      cpf: user.cpf,
      token: token
    }
  end
end
