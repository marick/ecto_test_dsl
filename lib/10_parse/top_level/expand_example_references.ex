defmodule TransformerTestSupport.Parse.TopLevel.ExpandExampleReferences do
  use TransformerTestSupport.Drink.Me

  @moduledoc """
  This is a second pass of processing examples, following `Normalize`.
  The two passes could be consolidated. But let's hold off on that.
  """
  def build_time_expansion(new_pairs, existing_pairs) do
    Enum.reduce(new_pairs, existing_pairs, fn {new_name, new_example}, acc ->
      expanded = expand(new_example, :example, acc)
      [{new_name, expanded} | acc]
    end)
  end

  def expand(example, :example, existing_pairs) do
    example
    |> expand_like(existing_pairs)
    |> add_previously
  end

  def expand_like(example, existing_pairs) do
    params = Map.get(example, :params, [])
    case is_function(params) do
      true ->
        Map.put(example, :params, params.(existing_pairs))
      false ->
        example
    end
  end

  def add_previously(example) do
    params = Map.get(example, :params, [])
    old = Map.get(example, :previously, [])

    new =
      params
      |> KeywordX.filter_by_value(&FieldRef.match?/1)
      |> KeywordX.map_values(fn xref ->
          {:insert, xref.een}
         end)

    case {old, new} do
      {_, []} ->
        example
      {[], _} -> 
        Map.put(example, :previously, new)
      {_, _} ->
        Map.put(example, :previously, old ++ new)
    end
  end
end
