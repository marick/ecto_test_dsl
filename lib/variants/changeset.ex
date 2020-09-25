defmodule TransformerTestSupport.Variants.Changeset do

  alias TransformerTestSupport.Impl.Build

  defmacro build(instructions) do
    quote do
      defp create_test_data() do
        Build.create_test_data(unquote(instructions))
      end
    end
  end
      
  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Variants.Changeset, as: Variant
      use TransformerTestSupport.Impl.Predefines, Variant
      import Variant, only: [build: 1]

      def accept_example(example_name) do
        params = params(example_name)
        older = struct(module_under_test())
        module_under_test().changeset(older, params)
      end
    end
  end
end
