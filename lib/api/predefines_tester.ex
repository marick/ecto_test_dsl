defmodule TransformerTestSupport.Predefines.Tester do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport, as: T

      alias T.TestDataServer
      alias T.SmartGet
      alias T.RunningExample
      alias T.RunningExample.TraceServer
      alias T.KeywordX
        
      @name_of_test_data Module.split(__MODULE__)
      |> Enum.drop(-1) |> Module.safe_concat
      
      def test_data(), do: TestDataServer.test_data(@name_of_test_data)
      
      def example(name),
        do: SmartGet.Example.get(@name_of_test_data, name)
      
      def params(example_name) do
        check_workflow(example_name, stop_after: :params)
        |> Keyword.get(:params)
      end

      @trace_server_translations %{
        prefix: :prefix,
        trace: :emitting?,
        max_level: :max_level
      }
      
      def check_workflow(example_name, opts \\ []) do
        {trace_server_opts, other_opts} =
          KeywordX.split_and_translate_keys(opts, @trace_server_translations)
        try do
          TraceServer.update(trace_server_opts)
          example(example_name)
          |> RunningExample.run(other_opts)
        after
          TraceServer.reset
        end
      end
    end
  end
end
