defmodule BankApi.Transactions.Repository do
  import Ecto.Query, warn: false

  alias BankApi.{
    Transactions.Transaction,
    Repo
  }

  @spec list_user_transactions(binary(), Date.t(), Date.t()) :: [Transaction.t()]
  def list_user_transactions(user_id, start_date, end_date) do
    from(
      transaction in Transaction,
      where:
        fragment("?::date", transaction.inserted_at) >= ^start_date and
          fragment("?::date", transaction.inserted_at) <= ^end_date and
          (transaction.sender_id == ^user_id or transaction.receiver_id == ^user_id),
      order_by: [asc: transaction.inserted_at]
    )
    |> Repo.all()
  end

  @spec get_user_transaction(binary(), binary()) :: {:ok, Transaction.t()} | {:error, :not_found}
  def get_user_transaction(transaction_id, user_id) do
    case Repo.get_by(Transaction, id: transaction_id, sender_id: user_id) do
      nil ->
        {:error, :not_found}

      transaction ->
        {:ok, transaction}
    end
  end

  @spec create_transaction(map()) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def create_transaction(attrs) do
    %Transaction{}
    |> Transaction.create_changeset(attrs)
    |> Repo.insert()
  end

  @spec update_transaction(Transaction.t(), map()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def update_transaction(transaction, attrs) do
    transaction
    |> Transaction.update_changeset(attrs)
    |> Repo.update()
  end
end
