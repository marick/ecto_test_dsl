defmodule TransformerTestSupport.Impl.SmartGet.ChangesetChecks.AsCast do
  alias TransformerTestSupport.Impl.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
  alias Ecto.Changeset
    
  @moduledoc """
  """

  

  defp insertion_changeset(example, fields) do
    struct(example.metadata.module_under_test)
    |> Changeset.cast(Example.params(example), fields)
  end

  def add(changeset_checks, example, user_mentioned) do
    case Keyword.get_values(example.metadata.field_transformations, :as_cast) do
      [] ->
        changeset_checks
      lists ->
        fields = Enum.concat(lists) |> Checks.Util.remove_fields_named_by_user(user_mentioned)
        changeset = insertion_changeset(example, fields)
        changeset_checks
        |> combine(:changes, make_changes(changeset, fields))
        |> combine(:no_changes, make_no_changes(changeset, fields))
        |> combine(:errors, make_errors(changeset, fields))
    end
  end

  defp combine(so_far, _field, []), do: so_far

  defp combine(so_far, field, values) do
    so_far ++ [{field, values}]
  end

  defp flatmapper(relevant?, add_check) do 
    fn changeset, fields -> 
      Enum.flat_map(fields, fn field ->
        if relevant?.(field, changeset),
        do: [add_check.(field, changeset)],
        else: []
      end)
    end
  end

  defp field_has_changed(field, changeset),
    do: field in Map.keys(changeset.changes)
  defp check_changed_field_value(field, changeset),
    do: {field, changeset.changes[field]}

  defp field_is_unchanged(field, changeset),
    do: not field_has_changed(field, changeset)
  defp check_field_unchanged(field, _changeset),
      do: field

  defp field_has_errors(field, changeset), 
    do: field in Keyword.keys(changeset.errors)
  defp expect_error(field, changeset),
    do: {field, Keyword.get(changeset.errors, field) |> elem(0)}

  def make_changes(changeset, fields) do
    flatmapper(
      &field_has_changed/2,
      &check_changed_field_value/2).(changeset, fields)
  end

  def make_no_changes(changeset, fields) do
    flatmapper(
      &field_is_unchanged/2,
      &check_field_unchanged/2).(changeset, fields)
  end

  def make_errors(changeset, fields) do
    flatmapper(
      &field_has_errors/2,
      &expect_error/2).(changeset, fields)
  end
end
