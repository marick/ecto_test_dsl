defmodule TransformerTestSupport.Impl.BuildStructureValidation do
  import TransformerTestSupport.Impl.DidYouMean

  @top_level_requires MapSet.new([:module_under_test, :format, :variant])

#  @top_level_hidden MapSet.new([:__sources])

  @top_level_optional MapSet.new([])

  @top_level_allowed MapSet.union(@top_level_requires, @top_level_optional)

  def assert_acceptable_keys(map) do
    assert_required_fields(map)
    refute_extra_fields(map)
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

  # ----------------------------------------------------------------------------

  def keyset(map), do: MapSet.new(Map.keys(map))

  defp sorted_difference(first, second) do 
    MapSet.difference(first, second)
    |> Enum.into([])
    |> Enum.sort
  end  

  
end
