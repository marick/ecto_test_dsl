defmodule EctoTestDSL.Parse.Node.Fields do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias T.Parse.Node
  
  defstruct parsed: %{}, with_ensured_eens: %{}, eens: []

  def parse(kws), do: kws |> Enum.into(%{}) |> new
  def new(map), do: %__MODULE__{parsed: map}

  defimpl Node.Mergeable, for: Node.Fields do
    def merge(earlier, later),
      do: Node.Common.merge_parsed(Node.Fields, earlier, later)
  end

  defimpl Node.EENable, for: Node.Fields do
    def eens(%{eens: eens}), do: eens
    def ensure_eens(node, _default_module), do: Node.Common.ensure_eens(node)
  end

  defimpl Node.Exportable, for: Node.Fields do
    def export(node), do: node.with_ensured_eens
  end
end


