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

  def to_changeset_notation(changeset_assertions, interesting_fields, changeset) do
    start = %{changes: []}
    updated = 
      Enum.reduce(interesting_fields, start, fn field, acc ->
        cond do
          field in Map.keys(changeset.changes) ->
            Map.update!(acc, :changes, &([{field, changeset.changes[field]} | &1]))
          true ->
            acc
        end
      end)
    
    %{changes: Enum.reverse(updated.changes)}
  end
end
