defmodule EctoTestDSL.Predefines.Tester do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias EctoTestDSL, as: T

      alias T.TestDataServer
      alias T.Run
      alias T.TraceServer
      alias T.KeywordX
      alias T.Nouns.{TestData,Example}
        
      @name_of_test_data Module.split(__MODULE__)
      |> Enum.drop(-1) |> Module.safe_concat
      
      def test_data(), do: TestDataServer.test_data(@name_of_test_data)
      
      def example(name),
        do: TestData.example(@name_of_test_data, name)

      def params(example_name) do
        unformatted = 
          check_workflow(example_name, stop_after: :params)
          |> Keyword.get(:params)

        Run.Params.format_for_example(unformatted, example(example_name))
      end

      def check_workflow(example_name, opts \\ []) do
        updated = Keyword.put_new(opts, :run, :for_value)
        example = example(example_name)
        Run.check(example, updated)
      end

      def check_automatic_only(example_name, opts \\ []) do
        updated = Keyword.put_new(opts, :run, :automatic_only)
        example = example(example_name)
        Run.check(example, updated)
      end
    end
  end
end
