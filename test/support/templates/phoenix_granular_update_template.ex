defmodule Template.PhoenixGranular.Update do
  defmacro __using__(_) do
    quote do
      use EctoTestDSL.Variants.PhoenixGranular.Update
      
      def started(opts \\ []) do
        opts =
          Keyword.merge(
            [api_module: "the module under test is irrelevant",
             repo: "no database transactions are done in this test"],
            opts)
            
        start(opts)
      end
      
      def create_test_data, do: started()
      defoverridable create_test_data: 0
    end
  end
end
