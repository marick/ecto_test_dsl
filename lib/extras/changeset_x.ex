defmodule TransformerTestSupport.ChangesetX do
  alias Ecto.Changeset


  def changeset(fields \\ []) do
    fields = Enum.into(fields, %{})
    struct(Changeset, fields)
  end
    
  def valid_changeset(fields \\ []) do
    changeset(fields)
    |> Map.put(:valid?, true)
  end

  def invalid_changeset(fields \\ []) do
    changeset(fields)
    |> Map.put(:valid?, false)
  end

  def   valid_changes(fields), do:   valid_changeset(changes: Enum.into(fields, %{}))
  def invalid_changes(fields), do: invalid_changeset(changes: Enum.into(fields, %{}))
end
