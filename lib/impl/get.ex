defmodule TransformerTestSupport.Impl.Get do
  @moduledoc """
  """

  def exemplar(test_data, exemplar_name),
    do: test_data.exemplars[exemplar_name]

  def params(test_data, exemplar_name),
    do: exemplar(test_data, exemplar_name).params
end
