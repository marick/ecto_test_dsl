defmodule TransformerTestSupport.Impl.Build2 do
  alias TransformerTestSupport.Impl.{Agent,Normalize,Like}
  @moduledoc """
  """

  @starting_test_data %{
    format: :raw,
    examples: []
  }

  def start(data \\ %{})
  
  def start(data) when is_list(data), 
    do: start(Enum.into(data, %{}))

  def start(data) do
    @starting_test_data
    |> Map.merge(data)
    |> variant_adjustment(:start)
  end

  # # ----------------------------------------------------------------------------

  def category(so_far, _category, raw_examples) do
    earlier_examples = so_far.examples
    
    updated_examples =
      Normalize.as(:example_pairs, raw_examples)
      |> Like.add_new_pairs(earlier_examples)

    Map.put(so_far, :examples, updated_examples)
  end

  def make__params_like(previous_name, except: override_kws) do 
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
