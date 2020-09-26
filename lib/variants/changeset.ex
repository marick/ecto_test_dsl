defmodule TransformerTestSupport.Variants.Changeset do

  alias TransformerTestSupport.Impl.Build

  defmacro build(instructions) do
    quote do
      defp create_test_data() do
        start = unquote(instructions) |> Build.create_test_data
        Map.merge(
          start, %{
            # Placeholder if I decide to include the
            # "template methods" functions in the test_data, rather
            # than use module lookup.
            # accept_example: &start.module_under_test.accept_example/1
          })
      end
    end
  end
      
  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Variants.Changeset, as: Variant
      use TransformerTestSupport.Impl.Predefines, Variant
      import Variant, only: [build: 1]
      
      alias TransformerTestSupport.Impl.Validations

      def accept_example(example_name) do
        params = params(example_name)
        older = struct(module_under_test())
        module_under_test().changeset(older, params)
      end

      def validate_example(example_name) do
        changeset = accept_example(example_name)
        Validations.validate_changeset(changeset, example_name, test_data())
      end
    end
  end
end
