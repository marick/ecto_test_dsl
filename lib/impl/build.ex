defmodule TransformerTestSupport.Impl.Build do
  alias TransformerTestSupport.Impl.{Normalize,Like}
  @moduledoc """
  """

  import DeepMerge, only: [deep_merge: 2]

  @starting_test_data %{
    format: :raw,
    examples: [],
    field_transformations: %{}
  }

  def start_with_variant(variant_name, data),
    do: start([{:variant, variant_name} | data])

  def start(data \\ []) when is_list(data) do
    map_data = Enum.into(data, %{})
    
    @starting_test_data
    |> Map.merge(map_data)
    |> run_start_hook
  end

  @doc """
  May be useful for debugging
  """
  def example(acc, example_name),
    do: acc.examples |> Keyword.get(example_name)

  # # ----------------------------------------------------------------------------

  def category(so_far, category, raw_examples) do
    earlier_examples = so_far.examples
    
    updated_examples =
      Normalize.as(:example_pairs, raw_examples)
      |> run_example_hooks(variant(so_far), category)
      |> Like.add_new_pairs(earlier_examples)

    Map.put(so_far, :examples, updated_examples)
  end

  def field_transformations(so_far, module_name, opts) do
    deep_merge(so_far, %{field_transformations: %{module_name => opts}})
  end


  # ----------------------------------------------------------------------------

  def params(opts),
    do: {:params, Enum.into(opts, %{})}
  
  def params_like(example_name, opts),
    do: {:params, make__params_like(example_name, opts)}
  def params_like(example_name), 
    do: params_like(example_name, except: [])
    
  def changeset(opts), do: {:changeset, opts}

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

  defp variant(test_data), do: Map.get(test_data, :variant)

  defp has_hook?(nil, _hook_tuple), do: false
  
  defp has_hook?(variant, hook_tuple), 
    do: hook_tuple in variant.__info__(:functions)


  defp run_example_hooks(pairs, variant, category) do
    case has_hook?(variant, {:run_example_hook, 2}) do
      true ->
        for {example_name, example} <- pairs do
          {example_name, variant.run_example_hook(example, category)}
        end
      false ->
        pairs
    end
  end

  defp run_start_hook(%{variant: variant} = test_data_so_far) do
    case has_hook?(variant, {:run_start_hook, 1}) do
      true ->
        apply variant, :run_start_hook, [test_data_so_far]
      false ->
        test_data_so_far
    end
  end
  defp run_start_hook(top_level), do: top_level
  
  
end
