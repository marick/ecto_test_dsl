defmodule EctoTestDSL.Parse.Pnode.Params do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  alias Pnode.Common.FromPairs
  
  defstruct parsed: %{}, eens: []

  def parse(kws), do: FromPairs.parse(Pnode.Params, kws)

  defimpl Pnode.Mergeable, for: Pnode.Params do
    def merge(earlier, %Pnode.Params{} = later),
      do: FromPairs.merge(Pnode.Params, earlier, later)
  end

  defimpl Pnode.EENable, for: Pnode.Params do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Exportable, for: Pnode.Params do
    def export(node), do: Rnode.Params.new(node.parsed)
  end
end


