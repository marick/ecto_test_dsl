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
end
