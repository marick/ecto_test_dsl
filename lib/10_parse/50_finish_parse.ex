defmodule EctoTestDSL.Parse.FinishParse do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  import DeepMerge, only: [deep_merge: 2]
  alias T.Parse.Node
  use Magritte

  @moduledoc """
  """

  def finish(test_data) do
    test_data.examples
    |> transform_examples(test_data)
    |> KeywordX.functor_map(&Node.Group.export/1)
    |> Map.put(test_data, :examples, ...)
  end

  defp transform_examples(examples, metadata) do
    Enum.reduce(examples, examples, fn {name, example}, acc ->
      example
      |> propagate_metadata(metadata)
      |> Node.Group.parse_time_substitutions(acc)
      |> Node.Group.handle_eens(metadata.examples_module)
      # Note: it is important for each example to be put in the
      # keyword list as it's finished because later examples can
      # refer back to earlier ones.
      |> put_in(acc, [name], ...)
    end)
  end

  defp propagate_metadata(example, test_data) do
    metadata = Map.delete(test_data, :examples) # Let's not have a recursive structure.
    deep_merge(example, %{metadata: metadata})
  end
end