defmodule TransformerTestSupport.Predefines.Tester do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport, as: T

      alias T.TestDataServer
      alias T.SmartGet
      alias T.Runner
        
      @name_of_test_data Module.split(__MODULE__)
      |> Enum.drop(-1) |> Module.safe_concat
      
      def test_data(), do: TestDataServer.test_data(@name_of_test_data)
      
      def example(name),
        do: SmartGet.Example.get(@name_of_test_data, name)
      
      def params(example_name) do 
        SmartGet.Example.get(@name_of_test_data, example_name)
        |> SmartGet.Example.params
      end
      
      def check_workflow(example_name, opts \\ []),
        do: Runner.run_example_steps(example(example_name), opts)
    end
  end
end
