defmodule BankApi.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias BankApi.Accounts.User

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
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :reverted_at, :sender_id, :receiver_id])
    |> validate_required([:amount, :sender_id, :receiver_id])
  end
end
