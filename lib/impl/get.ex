defmodule TransformerTestSupport.Impl.Get do
  alias TransformerTestSupport.Impl.TestDataServer
    
  @moduledoc """
  """

  def test_data(test_data_module),
    do: TestDataServer.test_data(test_data_module)

  def example(test_data_module, example_name) when is_atom(test_data_module),
    do: test_data(test_data_module) |> example(example_name)
  
  def example(test_data, example_name) do
    case test_data.examples[example_name] do
      nil ->
        raise "There is no example named `#{inspect example_name}`"
      retval ->
        retval
    end
  end
  
  def raw_params(test_data, example_name),
    do: example(test_data, example_name).params
end
