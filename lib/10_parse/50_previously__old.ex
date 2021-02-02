defmodule EctoTestDSL.Parse.Previously do
  use EctoTestDSL.Drink.Me

  # ----------------------------------------------------------------------------
  # Working with a container of one or more example sources


  def ensure_references(named_examples, default_module) do
    KeywordX.map_over_values(named_examples, fn example ->
      ensure_one_example(example, default_module)
    end)
  end

  def ensure_one_example(example, default_module) do
    Map.update(example, :setup_instructions, [], fn instructions ->
      Enum.flat_map(instructions, &(expand_instructions &1, default_module))
    end)
  end

  def expand_instructions({:insert, {name, module}}, _) do
    [insert: een(name, module)]
  end

  def expand_instructions({:insert, name}, default_module) when is_atom(name) do
    [insert: een(name, default_module)]
  end

  def expand_instructions({:insert, names}, default_module) when is_list(names) do
    Enum.flat_map(names, fn name ->
      expand_instructions({:insert, name}, default_module)
    end)
  end

  def expand_instructions(instructions, default_module) when is_list(instructions) do
    Enum.flat_map(instructions, fn instruction -> 
      expand_instructions(instruction, default_module)
    end)
  end
end
