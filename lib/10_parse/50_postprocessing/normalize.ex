defmodule TransformerTestSupport.Parse.PostProcessing.Normalize do
  import  ExUnit.Assertions
  
  @moduledoc """
  """

  def as(:example_pairs, example_pairs) when is_list(example_pairs) do
    Enum.map(example_pairs, &(as :example_pair, &1))
  end

  def as(:example_pairs, _) do
    flunk "Examples must be given in a keyword list (in order for `like/2` to work)"
  end

  def as(:example_pair, {name, example}),
    do: {name, as(:example, example)}

  def as(:example, example) do
    example
    |> flatten_keywords
    |> ensure_map
    |> interior(:params)
  end

  def as(:params, args), do: ensure_map(args)

  def interior(map, key) do
    value = Map.get(map, key, :missing)    
    cond do
      value == :missing -> 
        map
      is_function(value) -> # Functions are expanded in a second pass. I is lazy.
        map
      true ->
        Map.put(map, key, as(key, value))
    end
  end

  # N^2 baby!
  def flatten_keywords(kws) do
    Enum.reduce(kws, [], fn current, acc ->
      case current do
        {:__flatten, list} ->
          acc ++ list
        current ->
          acc ++ [current]
      end
    end)
  end

  def ensure_map(x), do: Enum.into(x, %{})
end
