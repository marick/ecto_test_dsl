defmodule TransformerTestSupport.Parse.ExampleAdjustments do
  import  ExUnit.Assertions
  
  @moduledoc """
  """

  def adjust(:example_pairs, example_pairs) when is_list(example_pairs) do
    Enum.map(example_pairs, &(adjust :example_pair, &1))
  end

  def adjust(:example_pairs, _) do
    flunk "Examples must be given in a keyword list (in order for `like/2` to work)"
  end

  def adjust(:example_pair, {name, example}),
    do: {name, adjust(:example, example)}

  def adjust(:example, example) do
    example
    |> flatten_keywords
    |> ensure_map
    |> Map.update(:params, %{}, &(adjust(:params, &1)))
  end

  def adjust(:params, %__ParamsLike__{} = like) do
    # Functions are expanded in a second pass. I is lazy.
    like
  end

  def adjust(:params, map), do: ensure_map(map)

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
