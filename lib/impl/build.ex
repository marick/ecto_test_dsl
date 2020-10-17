defmodule TransformerTestSupport.Impl.Build do
  alias TransformerTestSupport.Impl.Build.{Normalize,Like}
  import DeepMerge, only: [deep_merge: 2]
  @moduledoc """
  """

  import DeepMerge, only: [deep_merge: 2]

  @starting_test_data %{
    format: :raw,
    examples: [],
    field_transformations: [],
    workflow: :insert
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


  def propagate_metadata(test_data) do
    test_data
  end

  # ----------------------------------------------------------------------------

  def category(so_far, category, raw_examples) do
    earlier_examples = so_far.examples

    run_variant(so_far, :assert_category_hook, [category])
    
    updated_examples =
      Normalize.as(:example_pairs, raw_examples)
      |> attach_category(category)
      |> Like.add_new_pairs(earlier_examples)

    Map.put(so_far, :examples, updated_examples)
  end

  defp attach_category(pairs, category) do
    for {name, example} <- pairs,
      do: {name, deep_merge(example, %{metadata: %{category_name: category}})}
  end

  def field_transformations(so_far, opts) do
    deep_merge(so_far, %{field_transformations: opts})
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

#  defp variant(test_data), do: Map.get(test_data, :variant)

  defp has_hook?(nil, _hook_tuple), do: false
  
  defp has_hook?(variant, hook_tuple), 
    do: hook_tuple in variant.__info__(:functions)

  defp run_variant(test_data, hook_name, rest_args) do
    hook_tuple = {hook_name, 1 + length(rest_args)}
    variant = Map.get(test_data, :variant)  
    case has_hook?(variant, hook_tuple) do
      true ->
        apply variant, hook_name, [test_data | rest_args]
      false ->
        test_data
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
