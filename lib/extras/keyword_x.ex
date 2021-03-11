defmodule EctoTestDSL.KeywordX do
  import FlowAssertions.Define.{Defchain,BodyParts}
  alias EctoTestDSL.KeyVal
  
  def translate_keys(opts, key_map) do
    Enum.flat_map(opts, fn {key,v} ->
      case Map.get(key_map, key) do
        nil -> []
        new_key -> [{new_key, v}]
      end
    end)
  end

  # this combination is stupid.
  def split_and_translate_keys(opts, key_map) do
    {translatable, retain} = Keyword.split(opts, Map.keys(key_map))
    {translate_keys(translatable, key_map), retain}
  end

  def delete(kvs, atom) when is_atom(atom), do: Keyword.delete(kvs, atom)
  def delete(kvs, atoms) when is_list(atoms),
    do: KeyVal.reject_by_key(kvs, &(&1 in atoms))


  @doc """
  `functor_map` extracts each value, maps it, then reassociates it with
  the original key
  """
  def functor_map(kvs, f) do
    map_one = fn {k, v} -> {k, f.(v)} end
    Enum.map(kvs, map_one)
  end

  def split_by_value_predicate(kvs, value_pred) do
    pair_pred = fn {_key, value} -> value_pred.(value) end
    split = Enum.group_by(kvs, pair_pred)

    %{true => Map.get(split, true, []),
      false => Map.get(split, false, []) }
  end



  # ----------------------------------------------------------------------------

  def update_matching_structs(kvs, s, f) do
    update_matching_structs(kvs, [s, f])
  end

  def update_matching_structs(list, ungrouped) do
    pairs = Enum.chunk_every(ungrouped, 2)
    for elt <- list do
      case elt do
        {k, v} -> 
          case struct_function(v, pairs) do
            nil -> {k,    v }
            f   -> {k, f.(v)}
          end
        _ -> elt
      end
    end      
  end

  def struct_function(value, struct_function_pairs) do
    Enum.find_value(struct_function_pairs, fn [struct_name, f] ->
      case is_struct(value, struct_name) do
        true -> f
        false -> false
      end
    end)
  end

  defchain assert_no_duplicate_keys(kws) do
    keys = Keyword.keys(kws)
    elaborate_assert(length(keys) == length(Enum.uniq(keys)),
      "Keyword list should not have duplicate keys",
      left: kws, right: keys)
  end

  def at_most_this_key?(kws, key) do
    case kws do
      [] -> true
      [{^key, _}] -> true
      _ -> false
    end
  end
end
