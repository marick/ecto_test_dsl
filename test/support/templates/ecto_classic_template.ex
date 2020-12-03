defmodule Template.EctoClassic.Insert do
  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Variants.EctoClassic.Insert
      
      def started(opts \\ []) do
        opts = Enum.into(opts, %{module_under_test: :irrelevant_module_under_test})
        start(
          module_under_test: opts.module_under_test,
          format: :raw,
          repo: :no_actual_repo
        )
      end
      
      def create_test_data, do: started()
      defoverridable create_test_data: 0
    end
  end
end
