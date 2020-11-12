defmodule TransformerTestSupport.Build.ParamShorthand do
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
    |> add_setup
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

  def add_setup(example) do
    params = Map.get(example, :params, [])
    old_setups = Map.get(example, :setup, [])

    new_setups =
      params
      |> Enum.filter(&example_reference?/1)
      |> Enum.map(fn {_, {_, extended_example_name, _}} ->
          {:insert, extended_example_name}
         end)

    case {old_setups, new_setups} do
      {_, []} ->
        example
      {[], _} -> 
        Map.put(example, :setup, new_setups)
      {_, _} ->
        Map.put(example, :setup, old_setups ++ new_setups)
    end
  end

  @setup_reference :__setup_reference

  def example_reference?({_key, value}) do
    is_tuple(value) && elem(value, 0) == @setup_reference
  end
  def example_reference?(_), do: false

  def setup_reference(extended_example_name, use_type),
    do: {@setup_reference, extended_example_name, use_type}
    
  
    
end
