defmodule EctoTestDSL.Parse.Pnode.Fields do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  
  defstruct parsed: %{}, eens: []

  def parse(kws), do: kws |> Enum.into(%{}) |> new
  def new(map) do 
    %__MODULE__{
      parsed: map,
      eens: Pnode.Common.extract_een_values(map)
    }
  end

  defimpl Pnode.Mergeable, for: Pnode.Fields do
    def merge(earlier, later),
      do: Pnode.Common.merge_parsed(Pnode.Fields, earlier, later)
  end

  defimpl Pnode.EENable, for: Pnode.Fields do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Exportable, for: Pnode.Fields do
    def export(node), do: node.parsed
  end
end
