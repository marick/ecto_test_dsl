defmodule TransformerTestSupport.TestBuild do
  import TransformerTestSupport.Build
  alias TransformerTestSupport.TestDataServer

  def one_workflow(workflow_opts), do: one_workflow([], workflow_opts)

  def one_workflow(workflow_name \\ :workflow_name, start_opts, workflow_opts) do
    start(start_opts)
    |> workflow(workflow_name, workflow_opts)
    |> propagate_metadata
  end

  def with_params(example_name, params) do
    one_workflow([{example_name, [params: params]}])
  end


  # Avoid the rigamarole of a whole Variant module.
  def stash(test_data, module),
    do: TestDataServer.put_value_into(test_data, module)
  
end
