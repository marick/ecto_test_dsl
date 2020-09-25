defmodule TransformerTestSupport.Impl.Get do
  @moduledoc """
  """

  def example(test_data, example_name),
    do: test_data.examples[example_name]

  def params(test_data, example_name),
    do: example(test_data, example_name).params
end
