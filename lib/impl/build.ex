defmodule TransformerTestSupport.Impl.Build do
  import TransformerTestSupport.Impl.DidYouMean
  @moduledoc """
  """

  @build_defaults %{
    exemplars: []
  }

  @top_level_requires MapSet.new(
    [:module_under_test,
    ]
  )

  @top_level_optional MapSet.new(
    [:exemplars,
    ]
  )

  @top_level_allowed MapSet.union(@top_level_requires, @top_level_optional)
        

  def build(keywords) when is_list(keywords),
    do: keywords |> Enum.into(%{}) |> build

  def build(map) when is_map(map) do
    Map.merge(@build_defaults, map)
    |> assert_required_fields
    |> refute_extra_fields
  end

  def to_strings(map) when is_map(map), do: map_to_strings(map)
  def to_strings(kws) when is_list(kws), do: Enum.into(kws, %{}) |> to_strings


  # ----------------------------------------------------------------------------

  def keyset(map), do: MapSet.new(Map.keys(map))

  defp sorted_difference(first, second) do 
    MapSet.difference(first, second)
    |> Enum.into([])
    |> Enum.sort
  end  

  defp assert_required_fields(map) do 
    missing = sorted_difference(@top_level_requires, keyset(map))
    if Enum.empty?(missing) do
      map
    else
      raise "The following fields are required: #{inspect missing}"
    end
  end

  defp refute_extra_fields(map) do
    extras = sorted_difference(keyset(map), @top_level_allowed)
    if Enum.empty?(extras) do
      map
    else
      per_extra = did_you_mean(extras, @top_level_allowed)
      message = Enum.join(["The following fields are unknown:\n" | per_extra], "")
      raise message
    end
  end

  defp map_to_strings(map) when is_map(map) do
    map
    |> Enum.map(fn {k,v} -> {value_to_string(k), value_to_string(v)} end)
    |> Map.new
  end


  defp value_to_string(value) when is_list(value),
    do: Enum.map(value, &to_string/1)
  defp value_to_string(value) when is_map(value),
    do: map_to_strings(value)
  defp value_to_string(value),
      do: to_string(value)


end
