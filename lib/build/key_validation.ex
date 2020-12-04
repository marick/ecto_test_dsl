defmodule TransformerTestSupport.Build.KeyValidation do
  alias TransformerTestSupport.Messages
  import FlowAssertions.Define.{Defchain,BodyParts}
  
  defchain assert_valid_keys(map, required, optional) do
    missing = diff(required, Map.keys(map))
    extras = diff(Map.keys(map), optional) |> diff(required)
    elaborate_assert(Enum.all?([missing, extras], &Enum.empty?/1),
      Messages.invalid_keys,
      left: [missing: missing, extras: extras])
  end


  defp diff(larger, smaller) do
    larger_set = MapSet.new(larger)
    smaller_set = MapSet.new(smaller)
    MapSet.difference(larger_set, smaller_set) |> Enum.into([])
  end
end
