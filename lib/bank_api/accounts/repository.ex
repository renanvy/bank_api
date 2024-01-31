defmodule BankApi.Accounts.Repository do
  import Ecto.Query, warn: false

  alias BankApi.{Accounts.User, Repo}

  @spec get_user!(binary()) :: User.t() | no_return()
  def get_user!(id), do: Repo.get!(User, id)

  @spec get_user_and_lock(binary()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user_and_lock(id) do
    from(
      users in User,
      where: users.id == ^id,
      lock: fragment("FOR UPDATE OF ?", users)
    )
    |> Repo.one()
    |> case do
      nil ->
        {:error, :user_not_found}

      user ->
        {:ok, user}
    end
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.create_changeset(attrs)
    |> Repo.insert()
  end

  @spec update_balance(User.t(), Decimal.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_balance(%User{} = user, new_balance) do
    user
    |> User.update_balance_changeset(%{balance: new_balance})
    |> Repo.update()
  end

  @spec debit_balance(User.t(), Decimal.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def debit_balance(sender, amount) do
    new_balance = Decimal.sub(sender.balance, amount)
    update_balance(sender, new_balance)
  end

  @spec credit_balance(User.t(), Decimal.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def credit_balance(receiver, amount) do
    new_balance = Decimal.add(receiver.balance, amount)
    update_balance(receiver, new_balance)
  end
end
