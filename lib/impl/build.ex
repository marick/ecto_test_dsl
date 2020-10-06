defmodule TransformerTestSupport.Impl.Build do
  alias TransformerTestSupport.Impl.{Agent,Normalize,Like}
  @moduledoc """
  """

  @starting_test_data %{
    format: :raw,
    examples: []
  }

  def start(test_data_module, data \\ %{})
  
  def start(test_data_module, data) when is_list(data), 
    do: start(test_data_module, Enum.into(data, %{}))

  def start(test_data_module, data) do
    all =
      @starting_test_data
      |> Map.merge(data)
      |> variant_adjustment(:start)
    
    Agent.start_test_data(test_data_module, all)
    :ok
  end

  # ----------------------------------------------------------------------------

  def category(test_data_module, _category, raw_examples) do
    earlier_examples = Agent.test_data(test_data_module).examples

    updated_examples =
      Normalize.as(:example_pairs, raw_examples)
      |> Like.expand(:example_pairs, earlier_examples)
    
    Agent.deep_merge(test_data_module, %{examples: updated_examples})
  end

  def params_like_function(previous_name),
    do: params_like_function(previous_name, except: [])

  def params_like_function(previous_name, except: override_kws) do 
    overrides = Enum.into(override_kws, %{})
    fn named_examples ->
      Map.merge(
        Keyword.get(named_examples, previous_name).params,
        overrides)
    end
  end

  # ----------------------------------------------------------------------------

  
  defp variant_adjustment(%{variant: variant} = top_level, :start) do
    variant.adjust_top_level(top_level)
  end

  defp variant_adjustment(top_level, _), do: top_level
  
  
end
