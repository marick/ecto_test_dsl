defmodule EctoTestDSL.Parse.Pnode.Fields do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  alias Pnode.Common.FromPairs
  alias Pnode.Fields, as: This
  
  defstruct parsed: %{}, eens: []

  def parse(kws), do: FromPairs.parse(This, kws)

  defimpl Pnode.Mergeable, for: This do
    def merge(earlier, %This{} = later),
      do: FromPairs.merge(This, earlier, later)
  end

  defimpl Pnode.EENable, for: This do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Exportable, for: This do
    def export(node), do: node.parsed
  end
end
