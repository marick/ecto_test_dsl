defmodule TransformerTestSupport.Variants.Trivial do
  alias TransformerTestSupport.Build
  
  def start(opts), do: Build.start_with_variant(__MODULE__, opts)

  # ------------------- Hook functions -----------------------------------------

  def steps do
    []
  end     

  def run_start_hook(top_level) do
    top_level
    |> Map.put(:steps, %{})
    |> Map.put(:workflows, [])
  end

  # Anything is valid
  def assert_workflow_hook(_, _workflow) do
  end

  # ----------------------------------------------------------------------------

  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Predefines
      alias TransformerTestSupport.Variants.Trivial

      def start(opts), do: Trivial.start(opts)

      defmodule Tester do
        use TransformerTestSupport.Predefines.Tester
      end
    end
  end
end
