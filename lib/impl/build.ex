defmodule TransformerTestSupport.Impl.Build do
  alias TransformerTestSupport.Impl.{Agent,Normalize}
  @moduledoc """
  """

  @starting_test_data %{
    format: :raw
  }

  def start(test_data_module, data \\ %{})
  
  def start(test_data_module, data) when is_list(data), 
    do: start(test_data_module, Enum.into(data, %{}))

  def start(test_data_module, data) do
    all =
      @starting_test_data
      |> Map.merge(data)
      |> variant_adjustment(:start)
    
    Agent.add_test_data(test_data_module, all)
    :ok
  end

  # ----------------------------------------------------------------------------

  def category(test_data_module, _category, raw_examples) do
    normalized = Normalize.as(:example_pairs, raw_examples)
    Agent.deep_merge(test_data_module, %{examples: normalized})
  end

  # ----------------------------------------------------------------------------

  
  defp variant_adjustment(%{variant: variant} = top_level, :start) do
    variant.adjust_top_level(top_level)
  end

  defp variant_adjustment(top_level, _), do: top_level
  
  
end
