defmodule TransformerTestSupport.Impl.SmartGet.Changeset do
  alias TransformerTestSupport.Impl.SmartGet
    
  @moduledoc """
  """

  def get(test_data, example_name) do
    example = SmartGet.example(test_data, example_name)

    Map.get(example, :changeset, [])
    |> add_validity_check(example.category)
    |> add_field_transformations(test_data.field_transformations, example)
  end

  defp add_validity_check(changeset, category) do
    if category == :validation_failure,
      do:   [:invalid | changeset],
      else: [  :valid | changeset]
  end

  defp add_field_transformations(changeset, [], _), do: changeset
  
  defp add_field_transformations(changeset, [{field, _type}], example) do
    as_cast_value = example.params[field]
    changeset ++ [changes: [{field, as_cast_value}]]
  end
end
