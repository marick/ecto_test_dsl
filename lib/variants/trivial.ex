defmodule EctoTestDSL.Variants.Trivial do
  use EctoTestDSL.Drink.Me
  alias T.Variants.Trivial, as: ThisVariant
  alias T.Parse.Start
  
  def start(opts \\ []) do
    Start.start_with_variant(ThisVariant, opts)
  end

  # ------------------- Hook functions -----------------------------------------

  def steps do
    []
  end     

  def hook(:start, test_data, []) do
    test_data
    |> Map.put(:steps, %{})
    |> Map.put(:workflows, %{})
  end

  def hook(_, test_data, _), do: test_data

  # ----------------------------------------------------------------------------

  defmacro __using__(_) do
    quote do
      use EctoTestDSL.Predefines
      alias EctoTestDSL.Variants.Trivial

      def start(opts), do: Trivial.start(opts)

      defmodule Tester do
        use EctoTestDSL.Predefines.Tester
      end
    end
  end
end
