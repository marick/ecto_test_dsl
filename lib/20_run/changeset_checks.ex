defmodule TransformerTestSupport.Run.ChangesetChecks do
  use TransformerTestSupport.Drink.Me

  def unique_fields(changeset_checks) do
    changeset_checks
    |> Enum.filter(&is_tuple/1)
    |> Keyword.values
    |> Enum.flat_map(&from_check_args/1)
    |> Enum.uniq
  end

  defp from_check_args(field) when is_atom(field), do: [field]
  defp from_check_args(list) when is_list(list), do: Enum.map(list, &field/1)
  defp from_check_args(map)  when is_map(map), do: Enum.map(map,  &field/1)

  defp field({field, _value}), do: field
  defp field(field), do: field
end
