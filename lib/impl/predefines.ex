defmodule TransformerTestSupport.Impl.Predefines do
  @moduledoc """
  """

  defmacro __using__(_variant_module) do
    quote do
      import TransformerTestSupport.Impl.Build
      alias TransformerTestSupport.Impl.Get

      def test_data() do
        case TransformerTestSupport.get(__MODULE__) do
          nil -> 
            TransformerTestSupport.put(__MODULE__, create_test_data())
            test_data()
          example_data ->
            example_data
        end
      end

      def module_under_test(),
        do: test_data().module_under_test

      def params(example_name) do
        Get.params(test_data(), example_name)
      end

      def validate_category(category_name),
        do: validate_categories([category_name])
    end
  end
end
