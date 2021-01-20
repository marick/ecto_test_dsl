defmodule Template.PhoenixClassic.Insert do
  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Variants.PhoenixClassic.Insert
      
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
