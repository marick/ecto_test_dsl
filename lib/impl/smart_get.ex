defmodule TransformerTestSupport.Impl.SmartGet do
  alias TransformerTestSupport.Impl.{SmartGet,TestDataServer}

  def test_data(test_data_module),
    do: TestDataServer.test_data(test_data_module)

  @functions [
    example: SmartGet.Example,
    params: SmartGet.Params,
    changeset: SmartGet.ChangesetChecks
  ]

  for {name, module} <- @functions do
    def unquote(name)(test_data_module, example_name) when is_atom(test_data_module),
      do: unquote(module).get(SmartGet.test_data(test_data_module), example_name)

    def unquote(name)(global, example_name),
      do: unquote(module).get(global, example_name)
  end
end
