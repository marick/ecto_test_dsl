defmodule TransformerTestSupport.Impl.SmartGet.Example do
  alias TransformerTestSupport.Impl.SmartGet
  
  @moduledoc """
  """

  def get(test_data_module, example_name) when is_atom(test_data_module),
    do: SmartGet.test_data(test_data_module) |> get(example_name)
  
  def get(test_data, example_name) do
    case test_data.examples[example_name] do
      nil ->
        raise "There is no example named `#{inspect example_name}`"
      retval ->
        retval
    end
  end
end
