defmodule TransformerTestSupport.Parse.Start do
  use TransformerTestSupport.Drink.Me
  alias T.Parse.TopLevel.Validate
  alias T.Nouns.{FieldCalculator,AsCast}
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

  def start_with_variant(variant_name, data),
    do: start([{:variant, variant_name} | data])

  def start(data \\ []) when is_list(data) do
    map_data = Enum.into(data, %{})
    
    @starting_test_data
    |> Map.merge(map_data)
    |> Hooks.run_start_hook
  end



end  
