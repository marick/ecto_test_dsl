defmodule EctoTestDSL.Parse.Callbacks do
  use EctoTestDSL.Drink.Me
  use T.Drink.Assertively
  alias T.Parse.Start

  @required_keys [:module_under_test, :variant] ++ Map.keys(Start.starting_test_data)
  @optional_keys []

  def validate_top_level_keys(test_data, variant_required, variant_optional) do
    required = @required_keys ++ variant_required
    optional = @optional_keys ++ variant_optional
    assert_valid_keys(test_data, required, optional)
  end


  defchain assert_valid_keys(map, required, optional) do
    missing = EnumX.difference(required, Map.keys(map))
    extras = EnumX.difference(Map.keys(map), optional) |> EnumX.difference(required)
    elaborate_assert(Enum.all?([missing, extras], &Enum.empty?/1),
      Messages.invalid_keys,
      left: [missing: missing, extras: extras])
  end
end
