defmodule TransformerTestSupport.Impl.SmartGet do
  alias TransformerTestSupport.Impl.SmartGet.Params

  def params(global, example_name), do: Params.get(global, example_name)

end
