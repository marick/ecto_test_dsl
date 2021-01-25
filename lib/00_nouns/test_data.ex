defmodule EctoTestDSL.Nouns.TestData do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias EctoTestDSL.TestDataServer
  
  @moduledoc """
  All that's known of test data outside of parsing is how to get an
  example out of it.
  """

  def example(test_data_module, example_name) when is_atom(test_data_module),
    do: example(TestDataServer.test_data(test_data_module), example_name)
  
  def example(test_data, example_name) do
    case Keyword.get(test_data.examples, example_name) do
      nil ->
        raise "There is no example named `#{inspect example_name}`"
      retval ->
        retval
    end
  end
end
