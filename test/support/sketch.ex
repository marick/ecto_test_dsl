defmodule TransformerTestSupport.Sketch do
  use TransformerTestSupport.Drink.Me
  alias T.Nouns.AsCast
  
  def example(name, workflow, example_fields \\ []) do
    default_metadata = %{
      field_transformations: [],
      format: :phoenix,
      as_cast: AsCast.nothing,
      field_calculators: []
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
end
