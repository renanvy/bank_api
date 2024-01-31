defmodule BankApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: binary(),
          cpf: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          opening_balance: Decimal.t(),
          balance: Decimal.t(),
          password: String.t(),
          password_hash: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :opening_balance, :decimal, default: 0.0
    field :balance, :decimal
    field :first_name, :string
    field :last_name, :string
    field :cpf, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :cpf, :opening_balance, :password])
    |> validate_required([:first_name, :last_name, :cpf, :opening_balance, :password])
    |> validate_number(:opening_balance, greater_than_or_equal_to: 0.0)
    |> validate_number(:balance, greater_than_or_equal_to: 0.0)
    |> unique_constraint(:cpf)
    |> password_hash()
    |> set_balance()
  end

  @doc false
  def update_balance_changeset(user, attrs) do
    user
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
    |> validate_number(:balance, greater_than_or_equal_to: 0.0, message: "insuficient balance")
  end

  defp set_balance(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{opening_balance: opening_balance}} ->
        put_change(changeset, :balance, opening_balance)

      _ ->
        changeset
    end
  end

  defp password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
