defmodule TransformerTestSupport.Impl.Predefines__2 do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Impl.Build__2, as: Build
      alias TransformerTestSupport.Impl.Get__2, as: Get
      alias TransformerTestSupport.Impl.Validations__2, as: Validations

      @name_of_test_data __MODULE__

      def start(global_data), 
        do: Build.start(@name_of_test_data, global_data)

      def category(category_name, examples),
          do: Build.category(@name_of_test_data, category_name, examples)

      def params(example_name),
        do: Get.params(@name_of_test_data, example_name)

      def validate(example_name),
        do: Validations.validate(@name_of_test_data, example_name)

    end
  end
end
