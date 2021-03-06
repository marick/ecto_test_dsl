defmodule EctoTestDSL.Parse.Start do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  alias T.Nouns.AsCast

  @moduledoc """
  """

  @starting_test_data %{
    format: :raw,
    examples: [],
    as_cast: AsCast.nothing,
    field_calculators: []
  }

  def starting_test_data, do: @starting_test_data

  def start_with_variant(variant_name, data) do 
    map_data = Enum.into(data, %{variant: variant_name})

    @starting_test_data
    |> Map.merge(map_data)
    |> Hooks.run_hook(:start)
    |> BuildState.put
  end
end
