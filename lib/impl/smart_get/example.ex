defmodule TransformerTestSupport.Impl.SmartGet.Example do
  alias TransformerTestSupport.Impl.SmartGet
  
  @moduledoc """
  """

  def get(test_data, example_name) do
    case test_data.examples[example_name] do
      nil ->
        raise "There is no example named `#{inspect example_name}`"
      retval ->
        retval
    end
  end
end
