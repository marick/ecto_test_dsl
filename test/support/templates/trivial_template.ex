defmodule Template.Trivial do
  defmacro __using__(_) do
    quote do 
      use EctoTestDSL.Variants.Trivial

      def started(opts \\ []) do
        opts =
          Keyword.merge(
            [module_under_test: :irrelevant_module_under_test,
             format: :raw,
             examples_module: :default_trivial_examples_module,
             examples: []],
            opts)
            
        start(opts)
      end
      
      def create_test_data, do: started()
      defoverridable create_test_data: 0
    end
  end
end

  
