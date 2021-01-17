defmodule Template.Dynamic do
  use TransformerTestSupport.Drink.Me
  alias T.Parse.TopLevel


  def configure(examples_module, module_under_test \\ :irrelevant_module_under_test) do
    examples_module.create_test_data()
    |> adjust_metadata(module_under_test: module_under_test)
  end
  

  def adjust_metadata(module, opts) when is_atom(module),
    do: module.create_test_data() |> adjust_metadata(opts)

  def adjust_metadata(test_data, opts) do
    Map.merge(test_data, Enum.into(opts, %{}))
  end

  def example(module_or_test_data, example_opts \\ []),
    do: example_in_workflow(module_or_test_data, :only_workflow, example_opts)

  def example_in_workflow(module_or_test_data, workflow_name, example_opts \\ [])

  def example_in_workflow(module, workflow_name, example_opts) when is_atom(module) do
    module.create_test_data() |> example_in_workflow(workflow_name, example_opts)
  end

  def example_in_workflow(test_data, workflow_name, example_opts) do
    test_data
    |> TopLevel.workflow(workflow_name, only_example: example_opts)
    |> TopLevel.propagate_metadata
    |> TestData.example(:only_example)
  end
end

  
