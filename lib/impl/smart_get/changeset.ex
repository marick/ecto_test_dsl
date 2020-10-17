defmodule TransformerTestSupport.Impl.SmartGet.Changeset do
  alias TransformerTestSupport.Impl.SmartGet
  alias TransformerTestSupport.Impl.SmartGet.ChangesetAsCast, as: Cast
    
  @moduledoc """
  """

  def get(test_data, example_name) do
    example = SmartGet.example(test_data, example_name)

    Map.get(example, :changeset, [])
    |> add_validity_check(example.metadata.category_name)
    |> add_field_transformations(test_data, example_name)
  end

  defp add_validity_check(changeset_checks, category) do
    if category == :validation_failure,
      do:   [:invalid | changeset_checks],
      else: [  :valid | changeset_checks]
  end

  defp add_field_transformations(changeset_checks, %{field_transformations: [_x | _y]} = test_data, example_name) do
    case Keyword.get(test_data.field_transformations, :as_cast) do
      nil ->
        changeset_checks
      fields ->
        changeset = 
          struct(test_data.module_under_test)
          |> Ecto.Changeset.cast(SmartGet.params(test_data, example_name), fields)
        notation = Cast.to_changeset_notation(changeset, fields)
        changeset_checks
        |> combine(:changes, notation.changes)
        |> combine(:no_changes, notation.no_changes)
        |> combine(:errors, notation.errors)
    end
  end
  defp add_field_transformations(changeset_checks, _, _), do: changeset_checks

  defp combine(so_far, _field, []), do: so_far

  defp combine(so_far, field, values) do
    so_far ++ [{field, values}]
  end
end
