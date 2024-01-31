defmodule BankApi.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias BankApi.Accounts.User

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: binary(),
          amount: Decimal.t(),
          reverted_at: DateTime.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          sender_id: binary(),
          receiver_id: binary()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :amount, :decimal
    field :reverted_at, :utc_datetime

    belongs_to :sender, User
    belongs_to :receiver, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :sender_id, :receiver_id])
    |> validate_required([:amount, :sender_id, :receiver_id])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:sender_id)
    |> foreign_key_constraint(:receiver_id)
    |> validate_same_accounts()
  end

  @doc false
  def update_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:reverted_at])
    |> validate_if_already_reverted(transaction)
  end

  defp validate_same_accounts(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{sender_id: sender_id, receiver_id: receiver_id}} ->
        if sender_id == receiver_id do
          add_error(changeset, :receiver_id, "can't be transfer to yourself")
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  defp validate_if_already_reverted(%Ecto.Changeset{valid?: true} = changeset, transaction) do
    reverted_at = get_change(changeset, :reverted_at)

    if reverted_at && transaction.reverted_at do
      add_error(changeset, :reverted_at, "transaction already reverted")
    else
      changeset
    end
  end

  defp validate_if_already_reverted(changeset, _), do: changeset
end
