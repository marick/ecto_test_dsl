defmodule EctoTestDSL.Parse.Node.Params do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias T.Parse.Node
  use Magritte
  
  defstruct [:parsed, :eens]

  def parse(kws), do: new(kws)
  def new(kws), do: %__MODULE__{parsed: kws}

  defimpl Node.EENable, for: Node.Params do
    def merge(%{parsed: earlier}, %{parsed: later}) do
      Node.Params.new(Keyword.merge(earlier, later))
    end

    def eens(%{eens: eens}), do: eens

    def ensure_eens(node, _default_module) do
      eens = 
        node.parsed
        |> FieldRef.relevant_pairs
        |> KeywordX.map_values(fn xref -> xref.een end)

      Map.put(node, :eens, eens)
    end
  end
end


