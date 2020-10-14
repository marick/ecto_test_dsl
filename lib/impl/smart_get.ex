defmodule TransformerTestSupport.Impl.SmartGet do
  alias TransformerTestSupport.Impl.{SmartGet,TestDataServer}

  def test_data(test_data_module),
    do: TestDataServer.test_data(test_data_module)

  def example(global, example_name), do: SmartGet.Example.get(global, example_name)
  def params(global, example_name), do: SmartGet.Params.get(global, example_name)
  def changeset(global, example_name), do: SmartGet.Changeset.get(global, example_name)
end
