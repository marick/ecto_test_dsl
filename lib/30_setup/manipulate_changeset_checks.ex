defmodule TransformerTestSupport.Link.ManipulateChangesetChecks do
  use TransformerTestSupport.Drink.Me

  def replace_field_refs(checks, examples) do
    tested_replace_check_values(checks,
      fn v -> is_struct(v, FieldRef) end,
      fn ref -> Map.get(examples, ref.een) |> Map.get(ref.field) end)
  end
  
  def tested_replace_check_values(checks, predicate, replacer) do
    inner_loop = fn 
        check_args when is_list(check_args) ->
          for elt <- check_args do
            case elt do
              {k, v} ->
                if predicate.(v) ,
                  do:   {k, replacer.(v)},
                  else: {k,           v }
              _ -> elt
            end
          end
          single_arg -> single_arg    # `change: :a`, for example.
        end
    
    for elt <- checks do
      case elt do
        {k, v} -> {k, inner_loop.(v)}
        _ -> elt                       # `:valid`, for example.
      end
    end      
  end

  # ----------------------------------------------------------------------------

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
