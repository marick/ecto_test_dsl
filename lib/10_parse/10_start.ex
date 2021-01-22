defmodule TransformerTestSupport.Parse.Start do
  use TransformerTestSupport.Drink.Me
  alias T.Nouns.AsCast
  alias T.Parse.Hooks

  @moduledoc """
  """

  @starting_test_data %{
    format: :raw,
    examples: [],
    field_transformations: [],     # Delete
    as_cast: AsCast.nothing,
    field_calculators: []
  }

  def starting_test_data, do: @starting_test_data

  def start_with_variant(variant_name, data) do 
    map_data = Enum.into(data, %{variant: variant_name})

    @starting_test_data
    |> Map.merge(map_data)
    |> Hooks.run_hook(:start)
  end
end
