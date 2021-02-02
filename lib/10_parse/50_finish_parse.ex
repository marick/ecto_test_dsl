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
        |> handle_params
        |> handle_eens(test_data.examples_module)
        |> simplify
        # |> ImpliedSetup.add_setup_required_by_refs__2
        # |> IO.inspect

      temp1 = Map.put(improved, :setup_instructions, Map.get(example, :setup_instructions, []))
      temp2 = Map.put(temp1, :params, improved.params__temp)

      put_in(acc, [:examples, name], temp2)
    end)

    updated_examples =
      test_data.examples
      |> Previously.ensure_references(test_data.examples_module)
      |> ImpliedSetup.add

    Map.put(test_data, :examples, updated_examples)
  end

  def handle_params(example) do
    Map.put(example, :params__temp, Node.Params.parse(example.params))
  end

  def handle_eens(example, examples_module) do
    setup_instructions = Map.get(example, :setup_instructions, [])

    example
    |> Map.put(:previously__temp, Node.Previously.parse(setup_instructions))
    |> Node.Group.handle_eens(examples_module)
  end

  def simplify(example) do
    x = Node.Group.simplify(example)
    # IO.puts("--------------")
    # IO.inspect x.params
    # IO.inspect x.params__temp
    x
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
