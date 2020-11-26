defmodule Template.Trivial do
  defmacro __using__(_) do
    quote do 
      use TransformerTestSupport.Variants.Trivial
      
      def started() do
        start(
          module_under_test: __MODULE__,
          format: :phoenix,
          repo: :no_actual_repo
        )
      end
      
      def create_test_data do
        started()
      end
      defoverridable create_test_data: 0
    end
  end
end

  
