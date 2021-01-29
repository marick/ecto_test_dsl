defmodule EctoTestDSL.Parse.Node.Params do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias T.Parse.Node
  use Magritte
  
  defstruct [:kws]

  def parse(kws), do: new(kws)
  def new(kws), do: %__MODULE__{kws: kws}


  defimpl Node.EENable, for: Node.Params do
    def merge(%{kws: earlier}, %{kws: later}) do
      Node.Params.new(Keyword.merge(earlier, later))
    end

    def eens(%{eens: eens}), do: eens

    def ensure_eens(node, _default_module) do
      node
    end
  end
end


