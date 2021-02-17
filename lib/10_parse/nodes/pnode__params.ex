defmodule EctoTestDSL.Parse.Pnode.Params do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.AssertionJuice
  
  defstruct parsed: %{}, with_ensured_eens: %{}, eens: []

  def parse(kws), do: kws |> Enum.into(%{}) |> new
  def new(map), do: %__MODULE__{parsed: map}

  defimpl Pnode.Mergeable, for: Pnode.Params do
    def merge(earlier, later),
      do: Pnode.Common.merge_parsed(Pnode.Params, earlier, later)
  end

  defimpl Pnode.EENable, for: Pnode.Params do
    def eens(%{eens: eens}), do: eens
    def ensure_eens(node, _default_module) do
      Pnode.Common.with_ensured(node, Pnode.Common.extract_eens(node), node.parsed)
    end
  end

  defimpl Pnode.Exportable, for: Pnode.Params do
    def export(node), do: Rnode.Params.new(node.with_ensured_eens)
  end
end


