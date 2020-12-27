defmodule TransformerTestSupport.Sketch do
  use TransformerTestSupport.Drink.Me
  alias Ecto.Changeset
  alias T.Nouns.AsCast
  
  def example(name, workflow, example_fields \\ []) do
    default_metadata = %{
      field_transformations: [],
      format: :phoenix,
      as_cast: AsCast.nothing,
    }
    given_metadata = %{name: name, workflow_name: workflow}

    Enum.into(example_fields, %{})
    |> Map.put(:metadata, Map.merge(default_metadata, given_metadata))
  end

  def success_example, do:  example(:ok, :success)
  
  def merge_metadata(example, metadata_fields) do
    metadata_fields = Enum.into(metadata_fields, %{})
    DeepMerge.deep_merge(
      example,
      %{metadata: metadata_fields})
  end

  # ----------------------------------------------------------------------------

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
