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

  def field({field, _value}), do: field
  def field(field), do: field
    

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
