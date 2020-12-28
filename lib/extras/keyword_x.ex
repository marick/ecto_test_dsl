defmodule KeywordX do
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

  def filter_by_value(kvs, predicate),
    do: Enum.filter(kvs, fn {_k, v} -> predicate.(v) end)
  def reject_by_value(kvs, predicate),
    do: Enum.reject(kvs, fn {_k, v} -> predicate.(v) end)

  def filter_by_key(kvs, predicate), 
    do: Enum.filter(kvs, fn {k, _v} -> predicate.(k) end)
  def reject_by_key(kvs, predicate), 
    do: Enum.reject(kvs, fn {k, _v} -> predicate.(k) end)

  def delete(kvs, atom) when is_atom(atom), do: Keyword.delete(kvs, atom)
  def delete(kvs, atoms) when is_list(atoms),
    do: reject_by_key(kvs, &(&1 in atoms))

  def map_values(kvs, f) do
    Enum.map(kvs, fn {_k, v} -> f.(v) end)
  end

  def map_over_values(kvs, f) do
    Enum.map(kvs, fn {k, v} -> {k, f.(v)} end)
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

  
end
