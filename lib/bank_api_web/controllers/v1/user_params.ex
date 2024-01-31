defmodule BankApiWeb.V1.UserParams do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:start_date, :date)
    field(:end_date, :date)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:start_date, :end_date])
    |> validate_required([:start_date, :end_date])
    |> validate_date_ranges()
  end

  def validate(params) do
    case changeset(params) do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}

      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok, changes}
    end
  end

  defp validate_date_ranges(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{start_date: start_date, end_date: end_date}} ->
        if Date.compare(start_date, end_date) == :lt do
          changeset
        else
          add_error(changeset, :start_date, "start_date must be less than end_date")
        end

      _ ->
        changeset
    end
  end
end
