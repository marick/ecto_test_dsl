defmodule EctoTestDSL.Neighborhood.Expand do
  use EctoTestDSL.Drink.Me
  alias T.Nouns.RefHolder

  def values(kws, with: neighborhood) when is_map(kws),
    do: values_(kws, neighborhood, %{})

  def values(kws, with: neighborhood) when is_list(kws),
    do: values_(kws, neighborhood, [])

  def values_(kws, neighborhood, into) do
    for {name, value} <- kws, into: into do
      {name, one_value(value, neighborhood)}
    end
  end

  def one_value(value, neighborhood) do
    cond do
      RefHolder.impl_for(value) -> 
        RefHolder.dereference(value, in: neighborhood)
      is_map(value) ->
        values(value, with: neighborhood)
      KeywordX.is_keyword_list(value) ->
        Enum.map(value, &(values &1, with: neighborhood))
      is_list(value) ->
        Enum.map(value, &one_value(&1, neighborhood))
      true ->
        value
      end
  end

  # ----------------------------------------------------------------------------

  def changeset_checks(checks, examples) do
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
  
end
