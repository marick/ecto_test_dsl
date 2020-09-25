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
          exemplar_data ->
            exemplar_data
        end
      end

      def module_under_test(),
        do: test_data().module_under_test

      def params(exemplar_name) do
        Get.params(test_data(), exemplar_name)
      end
          
    end
  end
end
