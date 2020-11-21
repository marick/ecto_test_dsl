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

  def metadata!(example, field),
    do: Map.fetch!(example.metadata, field)

  def metadata(example, field),
    do: Map.get(example.metadata, field)


  def workflow_script(example, opts) do
    stop = Keyword.get(opts, :stop_after, :"this should not ever be a step name")

    attach_functions = fn step_names ->
      step_functions = step_functions(example)
      for name <- step_names, do: {name, step_functions[name]}
    end

    example
    |> step_list
    |> EnumX.take_until(&(&1 == stop))
    |> attach_functions.()
  end

  

  def step_functions(example), do: metadata!(example, :steps)
  def module_under_test(example), do: metadata!(example, :module_under_test)
  def format(example), do: metadata!(example, :format)
  def name(example), do: metadata!(example, :name)
  def workflow_name(example), do: metadata!(example, :workflow_name)
  def field_transformations(example), do: metadata!(example, :field_transformations)
  def previously(example), do: metadata!(example, :previously)
  def examples_module(example), do: metadata!(example, :examples_module)


  def repo(example), do: metadata(example, :repo)
  

  def step_list(example) do
    example.metadata.workflows
    |> Map.get(example.metadata.workflow_name)
  end

  IO.inspect "This is too error prone"
  # Because too easy to use it instead of SmartGet.Params
  def params(example, opts \\ [previously: %{}]),
    do: SmartGet.Params.get(example, opts)
end
