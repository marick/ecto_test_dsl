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

  def params(example), do: SmartGet.Params.get(example)
end
