defmodule EctoTestDSL.Parse.Pnode.Fields do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  alias Pnode.Common.FromPairs
  
  defstruct parsed: %{}, eens: []

  def parse(kws), do: FromPairs.parse(Pnode.Fields, kws)

  defimpl Pnode.Mergeable, for: Pnode.Fields do
    def merge(earlier, later),
      do: FromPairs.merge(Pnode.Fields, earlier, later)
  end

  defimpl Pnode.EENable, for: Pnode.Fields do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Exportable, for: Pnode.Fields do
    def export(node), do: node.parsed
  end
end
