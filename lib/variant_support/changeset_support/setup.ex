defmodule TransformerTestSupport.VariantSupport.ChangesetSupport.Setup do
  alias TransformerTestSupport.SmartGet.Example
  use FlowAssertions.Ecto
  alias TransformerTestSupport.Runner

  # ----------------------------------------------------------------------------
  # Working with a container of one or more example sources


  # setup(...), setup(...)
  def from_a_list(sources, example, prior_work),
    do: from_a_list(sources, example, prior_work, &(&1))

  # setup(insert: ..., insert: ...)
  def from_a_list(sources, example, prior_work, transform) do
    Enum.reduce(sources, prior_work,
      fn source, acc -> from_a_tuple(transform.(source), example, acc) end)
  end

  # ----------------------------------------------------------------------------
  # Working with an {:insert, ...} tuple.

  # setup(..., insert: [<ex1>, <ex2>], ...)
  def from_a_tuple({:insert, sources}, example, prior_work) when is_list(sources) do
    from_a_list(sources, example, prior_work, &({:insert, &1}))
  end

  # setup(..., insert: <ex1>, ...)
  def from_a_tuple({:insert, source}, example, prior_work) when is_atom(source) do
    example_module = Example.examples_module(example)
    from_a_leaf({source, example_module}, prior_work)
  end

  # setup(..., insert: {name, module}, ...)
  def from_a_tuple({:insert, extended_example_name}, _to_help_example, so_far),
    do: from_a_leaf(extended_example_name, so_far)

  # ----------------------------------------------------------------------------

  # At last, just the example name and module.
  def from_a_leaf({example_name, example_module} = extended_example_name, so_far) do
    unless_already_present(extended_example_name, so_far, fn ->
      workflow_results = 
        example_module
        |> Example.get(example_name)
        |> Runner.run_example_steps(previously: so_far)

      dependently_created = Keyword.get(workflow_results, :repo_setup)
      {:ok, insert_result} = Keyword.get(workflow_results, :insert_changeset)
      
      Map.put(dependently_created, {example_name, example_module}, insert_result)
    end)
  end
  
  # ----------------------------------------------------------------------------

  defp unless_already_present(extended_example_name, so_far, f) do 
    if Map.has_key?(so_far, extended_example_name), do: so_far, else: f.()
  end
end
