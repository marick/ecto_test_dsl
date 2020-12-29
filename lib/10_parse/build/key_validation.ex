defmodule TransformerTestSupport.Build.KeyValidation do
  use TransformerTestSupport.Drink.Me
  alias T.Messages
  import FlowAssertions.Define.{Defchain,BodyParts}
  
  defchain assert_valid_keys(map, required, optional) do
    missing = EnumX.difference(required, Map.keys(map))
    extras = EnumX.difference(Map.keys(map), optional) |> EnumX.difference(required)
    elaborate_assert(Enum.all?([missing, extras], &Enum.empty?/1),
      Messages.invalid_keys,
      left: [missing: missing, extras: extras])
  end
end
