defmodule EctoTestDSL.Parse.Node.Params do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias T.Parse.Node
  
  defstruct parsed: %{}, with_ensured_eens: %{}, eens: []

  def parse(kws), do: kws |> Enum.into(%{}) |> new
  def new(map), do: %__MODULE__{parsed: map}

  defimpl Node.Mergeable, for: Node.Params do
    def merge(earlier, later),
      do: Node.Common.merge_parsed(Node.Params, earlier, later)
  end

  defimpl Node.EENable, for: Node.Params do
    def eens(%{eens: eens}), do: eens
    def ensure_eens(node, _default_module) do
      Node.Common.with_ensured(node, Node.Common.extract_eens(node), node.parsed)
    end
  end

  defimpl Node.Exportable, for: Node.Params do
    def export(node), do: Run.Node.Params.new(node.with_ensured_eens)
  end
end


