defmodule TransformerTestSupport.Impl.SmartGet.ChangesetChecks do
  alias TransformerTestSupport.Impl.SmartGet
  alias Ecto.Changeset
    
  @moduledoc """
  """

  def get(example) do
    Map.get(example, :changeset, [])
    |> add_validity_check(example)
    |> add_field_transformations(example)
  end

  def get(test_data, example_name) do
    SmartGet.Example.get(test_data, example_name)
    |> get
  end
  

  defp add_validity_check(changeset_checks, example) do
    if example.metadata.category_name == :validation_failure,
      do:   [:invalid | changeset_checks],
      else: [  :valid | changeset_checks]
  end

  defp add_field_transformations(changeset_checks, example) do
    case Keyword.get(example.metadata.field_transformations, :as_cast) do
      nil ->
        changeset_checks
      fields ->
        changeset = 
          struct(example.metadata.module_under_test)
          |> Changeset.cast(SmartGet.Example.params(example), fields)
        notation = to_changeset_notation(changeset, fields)
        changeset_checks
        |> combine(:changes, notation.changes)
        |> combine(:no_changes, notation.no_changes)
        |> combine(:errors, notation.errors)
    end
  end
  defp add_field_transformations(changeset_checks, _, _, _) do
    changeset_checks
  end

  defp combine(so_far, _field, []), do: so_far

  defp combine(so_far, field, values) do
    so_far ++ [{field, values}]
  end


  def to_changeset_notation(changeset, interesting_fields) do
    %{changes: make_changes(changeset, interesting_fields),
      no_changes: make_no_changes(changeset, interesting_fields),
      errors: make_errors(changeset, interesting_fields)
    }
  end

  def make_changes(changeset, fields) do
    Enum.flat_map(fields, fn field ->
      if field in Map.keys(changeset.changes),
      do: [{field, changeset.changes[field]}],
      else: []
    end)
  end

  def make_no_changes(changeset, fields) do
    Enum.flat_map(fields, fn field ->
      if field in Map.keys(changeset.changes),
      do: [],
      else: [field]
    end)
  end

  def make_errors(changeset, fields) do
    Enum.flat_map(fields, fn field ->
      if field in Keyword.keys(changeset.errors),
      do: [{field, Keyword.get(changeset.errors, field) |> elem(0)}],
      else: []
    end)
  end
  
end
