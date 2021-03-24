defmodule EctoTestDSL.Run.ChangesetChecks do
  use EctoTestDSL.Drink.Me

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

  # ----------------------------------------------------------------------------
  def fields_mentioned(changeset_checks) do
    for top_element <- changeset_checks do
      case top_element do
        {_changeset_key, value} ->
          cond do
            is_list(value) ->
              for lower <- value do
                case lower do
                  {field, _value} ->  # [changed: [a: 5, ...], ...]
                    field
                  _ ->                # [changed: [:a, ...], ...]
                    lower             
                end
              end
            true ->                   # [changed: :a, ...]
              value
          end
        _ ->                          # [:valid, ...]
          []
      end
    end |> List.flatten
  end
  
end
