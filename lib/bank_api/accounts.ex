defmodule BankApi.Accounts do
  alias BankApi.{Accounts.Services.Authenticator, Accounts.Repository}

  defdelegate get_user!(id), to: Repository
  defdelegate get_user_and_lock(id), to: Repository
  defdelegate create_user(attrs), to: Repository
  defdelegate update_balance(user, amount), to: Repository
  defdelegate credit_balance(receiver, amount), to: Repository
  defdelegate debit_balance(sender, amount), to: Repository
  defdelegate authenticate_user(cpf, password), to: Authenticator, as: :call
end
