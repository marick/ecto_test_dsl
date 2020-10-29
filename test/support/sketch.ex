defmodule TransformerTestSupport.Sketch do
  alias Ecto.Changeset
  
  def example(name, category, example_fields \\ []) do
    default_metadata = %{field_transformations: [], format: :phoenix}
    given_metadata = %{name: name, category_name: category}

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
end
