defmodule TransformerTestSupport.Impl.Build do
  alias TransformerTestSupport.Impl.Agent
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
    adjust_example = fn {key, example} ->
      better_example = 
        example
        |> Enum.into(%{})
        |> adjust_params
      {key, better_example}
    end
    
    examples =
      raw_examples
      |> Enum.map(adjust_example)
      |> Map.new
    
    Agent.deep_merge(test_data_module, %{examples: examples})
  end


  defp adjust_params(%{params: params} = example) when is_list(params),
    do: Map.put(example, :params, Enum.into(params, %{}))

  defp adjust_params(example),
    do: example


  # ----------------------------------------------------------------------------

  
  defp variant_adjustment(%{variant: variant} = top_level, :start) do
    variant.adjust_top_level(top_level)
  end

  defp variant_adjustment(top_level, _), do: top_level
  
  
end
