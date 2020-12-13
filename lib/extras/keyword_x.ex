defmodule KeywordX do
  def translate(opts, key_map) do
    Enum.flat_map(opts, fn {key,v} ->
      case Map.get(key_map, key) do
        nil -> []
        new_key -> [{new_key, v}]
      end
    end)
  end

  def split_and_translate(opts, key_map) do
    {translatable, retain} = Keyword.split(opts, Map.keys(key_map))
    {translate(translatable, key_map), retain}
  end

  def filter_by_value(kvs, predicate) do
    Enum.filter(kvs, fn {_k, v} -> predicate.(v) end)
  end

  def map_values(kvs, f) do
    Enum.map(kvs, fn {_k, v} -> f.(v) end)
  end
end
