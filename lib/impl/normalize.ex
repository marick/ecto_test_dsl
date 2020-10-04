defmodule TransformerTestSupport.Impl.Normalize do
  @moduledoc """
  """

  def as(:example_pairs, example_pairs) do
    Enum.map(example_pairs, &(as :example_pair, &1))
    |> Map.new
  end

  def as(:example_pair, {name, example}),
    do: {name, as(:example, example)}

  def as(:example, example) do
    ensure_map(example)
    |> interior(:params)
  end

  def as(:params, args), do: ensure_map(args)

  def interior(map, key) do
    case Map.get(map, key, :missing) do
      :missing ->
        map
      interior ->
        Map.put(map, key, as(key, interior))
    end
  end

  def ensure_map(x), do: Enum.into(x, %{})
end
