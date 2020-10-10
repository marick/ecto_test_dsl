defmodule TransformerTestSupport.Impl.Predefines2 do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Impl.Build2, as: Build
      alias TransformerTestSupport.Impl.{Get,Validations,Like}

      # ----- Building test data ---------------------------------------------------

      @name_of_test_data __MODULE__

      def start(global_data),
        do: Build.start(global_data)

      def category(acc, category_name, examples),
        do: Build.category(acc, category_name, examples)

      def params(opts),
        do: {:params, Enum.into(opts, %{})}

      def params_like(example_name, opts),
        do: {:params, Build.make__params_like(example_name, opts)}
      def params_like(example_name), 
        do: params_like(example_name, except: [])

      def changeset(opts), do: {:changeset, opts}

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
