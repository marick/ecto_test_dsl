defmodule EctoTestDSL.Parse.TopLevel do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  use ExContract
  
  import DeepMerge, only: [deep_merge: 2]
  alias T.Nouns.AsCast

  # ----------------------------------------------------------------------------
  def field_transformations(opts) do
    BuildState.current
    |> field_transformations(opts)
    |> BuildState.put
  end

  # These separate files are because `field_transformations_test.exs` will
  # have to be rewritten to work with the above format

  def field_transformations(test_data, opts) do
    as_cast =
      AsCast.new(Keyword.get_values(opts, :as_cast) |> Enum.concat)

    calculators =
      opts
      |> Keyword.delete(:as_cast)
      |> KeywordX.assert_no_duplicate_keys

    test_data
    |> Map.update!(:as_cast, &(AsCast.merge(&1, as_cast)))
    |> Map.update!(:field_calculators, &(Keyword.merge(&1, calculators)))
    |> deep_merge(%{field_transformations: opts})
  end

  # ----------------------------------------------------------------------------
  def workflow(workflow, raw_examples) when is_list(raw_examples) do
    run_workflow_hook(workflow)

    for {name, raw_example} <- raw_examples do
      metadata =
        %{metadata: %{workflow_name: workflow, name: name}}
      cooked =
        raw_example
        |> testable_flatten
        |> Pnode.Group.squeeze_into_map
        |> deep_merge(metadata)

      BuildState.add_example({name, cooked})
    end

    # It's important to return the latest complete test data because
    # the result of `build_test_data` is the result of the final `workflow`.
    BuildState.current
  end

  def workflow(_, _, _supposed_examples),
    do: flunk "Examples must be given in a keyword list"

  defp run_workflow_hook(workflow) do
    BuildState.current
    |> Hooks.run_hook(:workflow, [workflow])
    |> BuildState.put
  end

  # N^2 baby!
  def testable_flatten(kws) do
    Enum.reduce(kws, [], fn current, acc ->
      case current do
        {:__flatten, list} ->
          acc ++ list
        current ->
          acc ++ [current]
      end
    end)
  end
  

  # ----------------------------------------------------------------------------
  @doc """
  May be useful for debugging
  """
  def example(test_data, example_name),
    do: test_data.examples |> Keyword.get(example_name)

end
