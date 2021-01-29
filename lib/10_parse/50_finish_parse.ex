defmodule EctoTestDSL.Parse.FinishParse do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  import DeepMerge, only: [deep_merge: 2]
  alias T.Parse.{Previously,ImpliedSetup, Node}
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
        |> handle_eens(test_data.examples_module)
        # |> ImpliedSetup.add_setup_required_by_refs__2
        # |> IO.inspect

      put_in(acc, [:examples, name], improved)
    end)

    updated_examples =
      test_data.examples
      |> Previously.ensure_references(test_data.examples_module)
      |> ImpliedSetup.add

    Map.put(test_data, :examples, updated_examples)
  end

  def handle_eens(example, examples_module) do
    put_existing_f = fn setup ->
      setup
      |> Node.Previously.parse
      |> Node.EENable.ensure_eens(examples_module)
    end

    new_example = 
      example
      |> put_existing(:setup_instructions, put_existing_f)
      |> get_existing(:setup_instructions, [], &Node.EENable.eens/1)
      |> IO.inspect
    
    example
  end

  def put_existing(example, key, f) do
    case Map.get(example, key) do
      nil ->
        example
      value ->
        Map.put(example, key, f.(value))
    end
  end

  def get_existing(example, key, default, f) do
    case Map.get(example, key) do
      nil ->
        default
      value ->
        f.(value)
    end
  end
  
        
  


  


  def propagate_metadata(example, test_data) do
    metadata = Map.delete(test_data, :examples) # Let's not have a recursive structure.
    deep_merge(example, %{metadata: metadata})
  end
end
