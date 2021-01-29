defmodule EctoTestDSL.Parse.FinishParse do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  import DeepMerge, only: [deep_merge: 2]
  alias T.Parse.{Previously,ImpliedSetup}
  use Magritte

  @moduledoc """
  """

  def finish(test_data) do
    examples = test_data.examples

    test_data = 
    Enum.reduce(examples, test_data, fn {name, example}, acc ->
      improved = 
        example
        |> propagate_metadata(test_data)

      put_in(acc, [:examples, name], improved)
    end)

    updated_examples =
      test_data.examples
      |> Previously.ensure_references(test_data.examples_module)
      |> ImpliedSetup.add

    Map.put(test_data, :examples, updated_examples)
  end


  def propagate_metadata(example, test_data) do
    metadata = Map.delete(test_data, :examples) # Let's not have a recursive structure.
    deep_merge(example, %{metadata: metadata})
  end
end
