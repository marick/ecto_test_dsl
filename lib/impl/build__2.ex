defmodule TransformerTestSupport.Impl.Build__2 do
#  import TransformerTestSupport.Impl.DidYouMean
  @moduledoc """
  """

  @starting_test_data %{
    format: :raw
  }

  def start(test_data_module, global_configuration \\ []) do
    top_level =
      Map.merge(
        @starting_test_data,
        valid_top_level(global_configuration))
    
    TransformerTestSupport__2.add_test_data(test_data_module, top_level)
  end

  def category(test_data_module, _category, examples) do
    map = %{
      examples: valid_examples(examples)
    }
    TransformerTestSupport__2.deep_merge(test_data_module, map)
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
