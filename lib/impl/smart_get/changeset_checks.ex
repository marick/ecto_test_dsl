defmodule TransformerTestSupport.Impl.SmartGet.ChangesetChecks do
  alias TransformerTestSupport.Impl.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
  alias Ecto.Changeset
    
  @moduledoc """
  """

  def get(example) do
    changeset_checks = Map.get(example, :changeset, [])
    user_mentioned = unique_fields(changeset_checks)

    changeset_checks
    |> Checks.Validity.add(example)
    |> add_as_cast_checks(example, user_mentioned)
  end

  def get(test_data, example_name) do
    Example.get(test_data, example_name)
    |> get
  end
  

  defp insertion_changeset(example, fields) do
    struct(example.metadata.module_under_test)
    |> Changeset.cast(Example.params(example), fields)
  end

  defp add_as_cast_checks(changeset_checks, example, user_mentioned) do
    case Keyword.get_values(example.metadata.field_transformations, :as_cast) do
      [] ->
        changeset_checks
      lists ->
        fields = Enum.concat(lists) |> remove_fields_named_by_user(user_mentioned)
        changeset = insertion_changeset(example, fields)
        changeset_checks
        |> combine(:changes, make_changes(changeset, fields))
        |> combine(:no_changes, make_no_changes(changeset, fields))
        |> combine(:errors, make_errors(changeset, fields))
    end
  end

  def unique_fields(changeset_checks) do
    changeset_checks
    |> Enum.filter(&is_tuple/1)
    |> Keyword.values
    |> Enum.flat_map(&from_check_args/1)
    |> Enum.uniq
  end

  def from_check_args(field) when is_atom(field), do: [field]
  def from_check_args(list) when is_list(list), do: Enum.map(list, &field/1)
  def from_check_args(map)  when is_map(map), do: Enum.map(map,  &field/1)

  def field({field, _value}), do: field
  def field(field), do: field
    

  def remove_fields_named_by_user(default_fields, reject_fields) do
    Enum.reject(default_fields, &Enum.member?(reject_fields, &1))
  end

  defp combine(so_far, _field, []), do: so_far

  defp combine(so_far, field, values) do
    so_far ++ [{field, values}]
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
