defmodule TransformerTestSupport.Parse.Previously do
  use TransformerTestSupport.Drink.Me

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
  
  # previously(...), previously(...)
  def from_a_list(sources, example, prior_work),
    do: from_a_list(sources, example, prior_work, &(&1))

  # previously(insert: ..., insert: ...)
  def from_a_list(sources, example, prior_work, transform) do
    Enum.reduce(sources, prior_work,
      fn source, acc -> from_a_tuple(transform.(source), example, acc) end)
  end

  # ----------------------------------------------------------------------------
  # Working with an {:insert, ...} tuple.

  # previously(..., insert: [<ex1>, <ex2>], ...)
  def from_a_tuple({:insert, sources}, example, prior_work) when is_list(sources) do
    from_a_list(sources, example, prior_work, &({:insert, &1}))
  end

  # previously(..., insert: <ex1>, ...)
  def from_a_tuple({:insert, source}, example, prior_work) when is_atom(source) do
    example_module = Example.examples_module(example)
    from_a_leaf({source, example_module}, prior_work)
  end

  # previously(..., insert: een{name, module}, ...)
  def from_a_tuple({:insert, %EEN{} = een}, _to_help_example, so_far),
    do: from_a_leaf(een, so_far)

  # previously(..., insert: {name, module}, ...)
  def from_a_tuple({:insert, extended_example_name}, _to_help_example, so_far),
    do: from_a_leaf(extended_example_name, so_far)

  # ----------------------------------------------------------------------------

  # At last, just the example name and module.
  def from_a_leaf({example_name, example_module}, so_far) do
    EEN.new(example_name, example_module)
    |> from_a_leaf(so_far)
  end
  
  # At last, just the example name and module.
  def from_a_leaf(%EEN{} = een, so_far) do
    unless_already_present(een, so_far, fn ->
      workflow_results = 
        een.module
        |> Example.get(een.name)
        |> Run.example(previously: so_far)

      dependently_created = Keyword.get(workflow_results, :previously)
      {:ok, insert_result} = Keyword.get(workflow_results, :insert_changeset)
      
      Map.put(dependently_created, een, insert_result)
    end)
  end
  
  # ----------------------------------------------------------------------------

  defp unless_already_present(extended_example_name, so_far, f) do 
    if Map.has_key?(so_far, extended_example_name), do: so_far, else: f.()
  end
end
