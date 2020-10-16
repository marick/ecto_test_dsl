defmodule TransformerTestSupport.Impl.SmartGet.ChangesetAsCast do
  alias TransformerTestSupport.Impl.SmartGet
  alias Ecto.Changeset

  def cast_only_changeset(module, fields, params) do
    Changeset.cast(struct(module), params, fields)
  end

  def as_cast_fields(test_data) do
    Enum.reduce(test_data.field_transformations, [], fn {field, descriptor}, acc ->
      if descriptor == :as_cast,
      do: [field | acc],
      else: acc
    end) |> Enum.reverse
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
