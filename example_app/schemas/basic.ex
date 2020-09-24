defmodule App.Schemas.Basic do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :lock_version, :integer
    field :date, :date
    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:lock_version, :date])
    |> validate_required(:date)
  end
end
