defmodule EctoTestDSL.Parse.TopLevel do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  
  import DeepMerge, only: [deep_merge: 2]
  alias T.Nouns.AsCast
  alias T.Parse.Hooks
  alias T.Parse.Node

  # ----------------------------------------------------------------------------
  def field_transformations(test_data, opts) do
    as_cast =
      AsCast.new(test_data.module_under_test,
        Keyword.get_values(opts, :as_cast) |> Enum.concat)

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
  def workflow(test_data, workflow, raw_examples) when is_list(raw_examples) do
    Hooks.run_hook(test_data, :workflow, [workflow])

    proper_examples = for {name, raw_example} <- raw_examples do
      metadata =
        %{metadata: %{workflow_name: workflow, name: name}}
      cooked =
        raw_example
        |> testable_flatten
        |> Node.Group.squeeze_into_map
        |> deep_merge(metadata)
      {name, cooked}
    end

    Map.update!(test_data, :examples, &(&1 ++ proper_examples))
  end

  def workflow(_, _, _supposed_examples),
    do: flunk "Examples must be given in a keyword list"

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
