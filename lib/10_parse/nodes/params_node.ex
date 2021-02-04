defmodule EctoTestDSL.Parse.Node.Params do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias T.Parse.Node
  use Magritte
  
  defstruct parsed: %{}, with_ensured_eens: %{}, eens: []

  def parse(kws), do: kws |> Enum.into(%{}) |> new
  def new(kws), do: %__MODULE__{parsed: kws}

  defimpl Node.EENable, for: Node.Params do
    def merge(%Node.Params{parsed: earlier}, %Node.Params{parsed: later}) do
      Node.Params.new(Map.merge(earlier, later))
    end

    def eens(%{eens: eens}), do: eens

    def ensure_eens(node, _default_module) do
      eens = 
        node.parsed
        |> FieldRef.relevant_pairs
        |> KeywordX.map_values(fn xref -> xref.een end)

      %{node | eens: eens, with_ensured_eens: node.parsed}
    end
  end

  defimpl Node.Exportable, for: Node.Params do
    def export(node) do
      node.with_ensured_eens |> Enum.into(%{})
    end
  end
end


