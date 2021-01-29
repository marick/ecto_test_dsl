defmodule EctoTestDSL.Parse.FinishParse do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  import DeepMerge, only: [deep_merge: 2]
  use Magritte

  @moduledoc """
  """

  def finish(test_data) do
    examples = test_data.examples

    Enum.reduce(examples, test_data, fn {name, example}, acc ->
      improved = 
        example
        |> propagate_metadata(test_data)

      put_in(acc, [:examples, name], improved)
    end)
  end


  def propagate_metadata(example, test_data) do
    metadata = Map.delete(test_data, :examples) # Let's not have a recursive structure.
    deep_merge(example, %{metadata: metadata})
  end
end
