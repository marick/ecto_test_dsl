defmodule TransformerTestSupport.Impl.Predefines do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      import TransformerTestSupport.Impl.Build
      alias TransformerTestSupport.Impl.{Get,Validations,Like}

      defmodule Tester do
        @name_of_test_data Module.split(__MODULE__) |> Enum.drop(-1) |> Module.safe_concat

        def test_data(), do: Get.test_data(@name_of_test_data)
        
        def example(name), do: Keyword.get(test_data().examples, name)

        def params(example_name),
          do: Get.params(@name_of_test_data, example_name)
        
        def validate(example_name),
          do: Validations.validate(@name_of_test_data, example_name)
      end
    end
  end
end
