defmodule TransformerTestSupport.SmartGet.Example do
  alias TransformerTestSupport.SmartGet
  alias TransformerTestSupport.TestDataServer
  
  @moduledoc """
  """

  def get(test_data_module, example_name) when is_atom(test_data_module),
    do: get(TestDataServer.test_data(test_data_module), example_name)
  
  def get(test_data, example_name) do
    case Keyword.get(test_data.examples, example_name) do
      nil ->
        raise "There is no example named `#{inspect example_name}`"
      retval ->
        retval
    end
  end

  def metadata(example, field),
    do: Map.fetch!(example.metadata, field)

  def step_functions(example), do: metadata(example, :steps)
  def module_under_test(example), do: metadata(example, :module_under_test)
  def format(example), do: metadata(example, :format)
  def name(example), do: metadata(example, :name)
  def category_name(example), do: metadata(example, :category_name)
  def field_transformations(example), do: metadata(example, :field_transformations)
  def repo(example), do: metadata(example, :repo)
  def setup(example), do: metadata(example, :setup)
  def examples_module(example), do: metadata(example, :examples_module)

  def step_list(example) do
    example.metadata.category_workflows
    |> Map.get(example.metadata.category_name)
  end

  def params(example), do: SmartGet.Params.get(example)
end
