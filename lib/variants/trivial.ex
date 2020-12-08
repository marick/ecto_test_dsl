defmodule TransformerTestSupport.Variants.Trivial do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.Variants.Trivial, as: ThisVariant
  
  def start(opts \\ []) do
    Build.start_with_variant(ThisVariant, opts)
  end

  # ------------------- Hook functions -----------------------------------------

  def steps do
    []
  end     

  def run_start_hook(top_level) do
    top_level
    |> Build.validate_keys_including_variant_keys([], [])
    |> Map.put(:steps, %{})
    |> Map.put(:workflows, %{})
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
