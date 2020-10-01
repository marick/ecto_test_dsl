defmodule TransformerTestSupport.Impl.Get__2 do
  import FlowAssertions.Define.BodyParts
    
  @moduledoc """
  """

  @doc """
  All data access must go through here so that the module is initialized.
  """
  def test_data(test_data_module),
    do: TransformerTestSupport__2.test_data(test_data_module)

  def params(test_data_module, example_name),
    do: test_data(test_data_module).examples[example_name].params
    
end
