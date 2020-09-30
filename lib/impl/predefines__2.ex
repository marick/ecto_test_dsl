defmodule TransformerTestSupport.Impl.Predefines__2 do
  @moduledoc """
  """

  defmacro __using__(_variant_module) do
    quote do
      import TransformerTestSupport.Impl.Build__2
      alias TransformerTestSupport.Impl.Get__2, as: Get

      def test_data() do
        case TransformerTestSupport.get(__MODULE__) do
          nil -> 
            TransformerTestSupport.put(__MODULE__, create_test_data())
            test_data()
          example_data ->
            example_data
        end
      end
    end
  end
end
