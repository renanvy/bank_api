defmodule BankApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :opening_balance, :decimal
    field :balance, :decimal
    field :first_name, :string
    field :last_name, :string
    field :cpf, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :cpf, :balance, :opening_balance])
    |> validate_required([:first_name, :last_name, :cpf, :balance, :opening_balance])
  end
end
