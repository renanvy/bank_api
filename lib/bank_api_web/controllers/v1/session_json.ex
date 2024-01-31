defmodule BankApiWeb.V1.SessionJSON do
  def user_token(%{user: user, token: token}) do
    %{
      id: user.id,
      token: token
    }
  end
end
