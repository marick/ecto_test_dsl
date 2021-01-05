defmodule TransformerTestSupport.Parse.Normalize do
  
  @moduledoc """
  """

  def as(:example_pairs, example_pairs) when is_list(example_pairs) do
    Enum.map(example_pairs, &(as :example_pair, &1))
  end

  def as(:example_pairs, _) do
  end

  def as(:example_pair, {name, example}),
    do: {name, as(:example, example)}

  def as(:example, example) do
    example
    |> flatten_keywords
    |> ensure_map
    |> Map.update(:params, %{}, &(as(:params, &1)))
  end

  # Functions are expanded in a second pass. I is lazy.
  def as(:params, %__ParamsLike__{} = like), do: like
  def as(:params, map), do: ensure_map(map)

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
