defmodule BankApi.Accounts.Services.Authenticator do
  import Ecto.Query, warn: false

  alias BankApi.{Accounts.User, Repo}

  @spec call(String.t(), String.t()) :: {:ok, User.t()} | {:error, :invalid_credentials}
  def call(cpf, password) do
    query = from(u in User, where: u.cpf == ^cpf)

    case Repo.one(query) do
      nil ->
        {:error, :invalid_credentials}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
