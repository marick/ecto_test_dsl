defmodule Template.PhoenixGranular.Insert do
  defmacro __using__(_) do
    quote do
      use EctoTestDSL.Variants.PhoenixGranular.Insert
      
      def started(opts \\ []) do
        opts =
          Keyword.merge(
            [module_under_test: :irrelevant_module_under_test,
             repo: :no_actual_repo],
            opts)
            
        start(opts)
      end
      
      def create_test_data, do: started()
      defoverridable create_test_data: 0
    end
  end
end
