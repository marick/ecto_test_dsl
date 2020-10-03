defmodule TransformerTestSupport.Impl.Get do
  import FlowAssertions.Define.BodyParts
    
  @moduledoc """
  """

  def example(test_data, example_name),
    do: test_data.examples[example_name]

  def params(test_data, example_name),
    do: example(test_data, example_name).params

  def all_example_names(test_data), do: Map.keys(test_data.examples)

  def names_in_categories(test_data, categories) do
    test_data
    |> filter_by_categories(all_example_names(test_data), categories)
  end

  def in_all_categories?(test_data, example_name, all_required_categories) do
    example_categories = 
      test_data
      |> example(example_name)
      |> Map.get(:categories, [])

    MapSet.difference(
      MapSet.new(all_required_categories),
      MapSet.new(example_categories))
    |> Enum.empty?
  end

  def filter_by_categories(test_data, names, all_required_categories) do
    ensure_valid_categories(test_data, all_required_categories)
    
    filter = fn name ->
      in_all_categories?(test_data, name, all_required_categories)
    end

    Enum.filter(names, filter)
  end

  def ensure_valid_categories(test_data, claimed) do
    valids =
      test_data.examples
      |> Map.values
      |> Enum.flat_map(&(Map.get(&1, :categories, [])))
      |> MapSet.new

    invalids =
      MapSet.new(claimed)
      |> MapSet.difference(valids)
      |> Enum.into([])

    elaborate_assert(Enum.empty?(invalids),
      "Categories you asked for don't exist",
      left: invalids)
  end
  
end
