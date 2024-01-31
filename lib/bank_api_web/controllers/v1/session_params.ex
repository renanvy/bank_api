defmodule BankApiWeb.V1.SessionParams do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:cpf, :string)
    field(:password, :string)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:cpf, :password])
    |> validate_required([:cpf, :password])
  end

  def validate(params) do
    case changeset(params) do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}

      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok, changes}
    end
  end
end
