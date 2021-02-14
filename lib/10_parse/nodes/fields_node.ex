defmodule EctoTestDSL.Parse.Pnode.Fields do
  use EctoTestDSL.Drink.Me
  use T.Parse.Drink.Me
  use T.Drink.AssertionJuice
  
  defstruct parsed: %{}, with_ensured_eens: %{}, eens: []

  def parse(kws), do: kws |> Enum.into(%{}) |> new
  def new(map), do: %__MODULE__{parsed: map}

  defimpl Pnode.Mergeable, for: Pnode.Fields do
    def merge(earlier, later),
      do: Pnode.Common.merge_parsed(Pnode.Fields, earlier, later)
  end

  defimpl Pnode.EENable, for: Pnode.Fields do
    def eens(%{eens: eens}), do: eens
    def ensure_eens(node, _default_module) do
      Pnode.Common.with_ensured(node, Pnode.Common.extract_eens(node), node.parsed)
    end
      
  end

  defimpl Pnode.Exportable, for: Pnode.Fields do
    def export(node), do: node.with_ensured_eens
  end
end
