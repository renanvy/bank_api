defmodule BankApiWeb.V1.UserJSON do
  alias BankApi.Accounts.User

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      cpf: user.cpf,
      opening_balance: user.opening_balance,
      balance: user.balance
    }
  end
end
