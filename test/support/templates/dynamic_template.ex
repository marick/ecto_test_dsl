defmodule Template.Dynamic do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.SmartGet.Example

  def adjust_metadata(test_data, opts) do
    Map.merge(test_data, Enum.into(opts, %{}))
  end

  def example(test_data, opts \\ []) do
    test_data
    |> Build.workflow(:only_workflow, only_example: opts)
    |> Build.propagate_metadata
    |> Example.get(:only_example)
  end

  def example_with_params(test_data, given_params) do
    test_data
    |> example([Build.params(given_params)])
  end
end

  
