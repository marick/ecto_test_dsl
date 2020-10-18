defmodule TransformerTestSupport.Impl.Predefines do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Impl
      import Impl.Build, except: [start: 1]  # Variant must define `start`.
      alias Impl.{Get,Validations,Build}
      alias Impl.SmartGet
      alias Impl.Build.Like
      

      defmodule Tester do
        alias TransformerTestSupport.Impl.TestDataServer
        alias TransformerTestSupport.Impl.SmartGet
        
        @name_of_test_data Module.split(__MODULE__)
          |> Enum.drop(-1) |> Module.safe_concat

        def test_data(), do: TestDataServer.test_data(@name_of_test_data)
        
        def example(name),
          do: SmartGet.Example.get(@name_of_test_data, name)

        def params(example_name),
          do: SmartGet.Params.get(@name_of_test_data, example_name)
        
        def validate(example_name),
          do: Validations.validate(@name_of_test_data, example_name)
      end
    end
  end
end
