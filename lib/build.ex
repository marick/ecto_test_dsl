defmodule TransformerTestSupport.Build do
  alias TransformerTestSupport.Build.{Normalize,ParamShorthand}
  import DeepMerge, only: [deep_merge: 2]
  import FlowAssertions.Define.BodyParts

  @moduledoc """
  """

  import DeepMerge, only: [deep_merge: 2]

  @starting_test_data %{
    format: :raw,
    examples: [],
    field_transformations: [],
    action: :insert
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
  def example(test_data, example_name),
    do: test_data.examples |> Keyword.get(example_name)

  def propagate_metadata(test_data) do
    metadata = Map.delete(test_data, :examples) # Let's not have a recursive structure.
    new_examples = 
      for {name, example} <- test_data.examples do
        {name, deep_merge(example, %{metadata: metadata})}
      end
    Map.put(test_data, :examples, new_examples)
  end

  def field_transformations(test_data, opts) do
    deep_merge(test_data, %{field_transformations: opts})
  end

  def replace_steps(test_data, replacements) do
    replacements = Enum.into(replacements, %{})
    DeepMerge.deep_merge(test_data, %{steps: replacements})
  end

  def step(f, key) do
    fn running ->
      Keyword.fetch!(running.history, key) |> f.()
    end
  end
  

  # ----------------------------------------------------------------------------

  def category(so_far, category, raw_examples) do
    earlier_examples = so_far.examples

    run_variant(so_far, :assert_category_hook, [category])
    
    updated_examples =
      Normalize.as(:example_pairs, raw_examples)
      |> attach_category_metadata(category)
      |> ParamShorthand.build_time_expansion(earlier_examples)
    Map.put(so_far, :examples, updated_examples)
  end

  defp attach_category_metadata(pairs, category) do
    for {name, example} <- pairs do
      metadata = %{metadata: %{category_name: category, name: name}}
      {name, deep_merge(example, metadata)}
    end
  end

  # ----------------------------------------------------------------------------

  def params(opts \\ []),
    do: {:params, Enum.into(opts, %{})}
  
  def params_like(example_name, opts),
    do: {:params, make__params_like(example_name, opts)}
  def params_like(example_name), 
    do: params_like(example_name, except: [])

  defmacro id_of([extended_example_name]) when is_tuple(extended_example_name) do
    quote do
        ParamShorthand.previously_reference(
          unquote(extended_example_name), :primary_key)
      end
    end
  defmacro id_of(example_name) when is_atom(example_name) do
    quote do
      ParamShorthand.previously_reference({
        unquote(example_name), __MODULE__}, :primary_key)
    end
  end


  # ----------------------------------------------------------------------------

  def previously(opts) do
    {:previously, opts}
  end

  def insert_twice(example_name),
    do: {:__flatten, [previously(insert: example_name), params_like(example_name)]}
    
  def changeset(opts), do: {:changeset_for_validation_step, opts}
  def constraint_changeset(opts), do: {:changeset_for_constraint_step, opts}

  defmacro on_success(funcall) do
    case Macro.decompose_call(funcall) do
      {{:__aliases__, _, aliases},  fun_atom, args} -> 
        composed_module = Enum.reduce(aliases, :Elixir, fn alias, acc ->
        Module.safe_concat(acc, alias)
      end)
        fun = Function.capture(composed_module, fun_atom, length(args))
        quote do
          {:__on_success, unquote(fun), unquote(args)}
        end

      {fun_atom, args} ->
        quote do 
          fun = Function.capture(__MODULE__, unquote(fun_atom), length(unquote(args)))
          {:__on_success, fun, unquote(args)}
        end

      _ ->
        raise """
        The argument to `on_success/1` does not look like a function call.
        You may want the `on_success(f, applied_to: args)` variant.
        """
    end
  end

  def on_success(f, applied_to: fields) when is_list(fields),
    do: {:__on_success, f, fields}
  def on_success(f, applied_to: field),
    do: on_success(f, applied_to: [field])


  @doc false
  # Exposed for testing.
  def make__params_like(previous_name, except: override_kws) do 
    overrides = Enum.into(override_kws, %{})
    fn named_examples ->
      case Keyword.get(named_examples, previous_name) do
        nil ->
          ex = inspect previous_name
          elaborate_flunk("There is no previous example `#{ex}`",
            right: Keyword.keys(override_kws))
        previous -> 
          Map.merge(previous.params, overrides)
      end
    end
  end

  # ----------------------------------------------------------------------------

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
