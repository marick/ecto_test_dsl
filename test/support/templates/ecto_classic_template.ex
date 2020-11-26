defmodule Template.EctoClassic do
  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Variants.EctoClassic
      
      def started() do
        EctoClassic.start(
          module_under_test: __MODULE__,
          format: :raw,
          repo: :no_actual_repo
        )
      end
      
      def create_test_data do
        started()
      end
    end
  end
end
