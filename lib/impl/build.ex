defmodule TransformerTestSupport.Impl.Build do
  alias TransformerTestSupport.Impl.Agent
  @moduledoc """
  """

  @starting_test_data %{
    format: :raw
  }

  def start(test_data_module, global_configuration \\ []) do
    top_level = valid_top_level(global_configuration)

    all =
      @starting_test_data
      |> Map.merge(top_level)
      |> adjust_top_level
    
    Agent.add_test_data(test_data_module, all)
  end

  defp adjust_top_level(%{variant: variant} = top_level) do
    variant.adjust_top_level(top_level)
  end

  defp adjust_top_level(top_level), do: top_level
  

  def category(test_data_module, _category, examples) do
    map = %{
      examples: valid_examples(examples)
    }
    Agent.deep_merge(test_data_module, map)
  end


  defp valid_top_level(global_configuration) do
    Enum.into(global_configuration, %{})    
  end

  defp valid_examples(examples) do
    examples
    |> Enum.map(&valid_example/1)
    |> Map.new
  end

  defp valid_example({key, example}) do
    better_example = 
      example
      |> Enum.into(%{})
      |> adjust_params
    {key, better_example}
  end

  defp adjust_params(%{params: params} = example) when is_list(params),
    do: Map.put(example, :params, Enum.into(params, %{}))

  defp adjust_params(example),
    do: example
  
end
