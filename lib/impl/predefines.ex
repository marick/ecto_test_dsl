defmodule TransformerTestSupport.Impl.Predefines do
  @moduledoc """
  """

  defmacro __using__(_variant_module) do
    quote do
      import TransformerTestSupport.Impl.Build
      alias TransformerTestSupport.Impl.Get

      def params(exemplar_name) do
        Get.params(test_data(), exemplar_name)
      end
          
    end
  end
end
