defmodule TransformerTestSupport.Impl.Build do
  alias TransformerTestSupport.Impl.{Normalize,Like}
  @moduledoc """
  """

  @starting_test_data %{
    format: :raw,
    examples: []
  }

  def start_with_variant(variant_name, data),
    do: start([{:variant, variant_name} | data])

  def start(data \\ []) when is_list(data) do
    map_data = Enum.into(data, %{})
    
    @starting_test_data
    |> Map.merge(map_data)
    |> run_variant_hook(:run_start_hook)
  end

  # # ----------------------------------------------------------------------------

  def category(so_far, _category, raw_examples) do
    earlier_examples = so_far.examples
    
    updated_examples =
      Normalize.as(:example_pairs, raw_examples)
      |> Like.add_new_pairs(earlier_examples)

    Map.put(so_far, :examples, updated_examples)
  end

  def params(opts),
    do: {:params, Enum.into(opts, %{})}
  
  def params_like(example_name, opts),
    do: {:params, make__params_like(example_name, opts)}
  def params_like(example_name), 
    do: params_like(example_name, except: [])
    
  def changeset(opts), do: {:changeset, opts}

  @doc """
  May be useful for debugging
  """
  def example(acc, example_name),
    do: acc.examples |> Keyword.get(example_name)
    

  @doc false
  # Exposed for testing.
  def make__params_like(previous_name, except: override_kws) do 
    overrides = Enum.into(override_kws, %{})
    fn named_examples ->
      Map.merge(
        Keyword.get(named_examples, previous_name).params,
        overrides)
    end
  end

  # ----------------------------------------------------------------------------

  
  defp run_variant_hook(%{variant: variant} = test_data_so_far, hook_name) do
    case {hook_name, 1} in variant.__info__(:functions) do
      true ->
        apply variant, hook_name, [test_data_so_far]
      false ->
        test_data_so_far
    end
  end

  defp run_variant_hook(top_level, _), do: top_level
  
  
end
