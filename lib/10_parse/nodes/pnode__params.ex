defmodule EctoTestDSL.Parse.Pnode.Params do
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

  defimpl Pnode.Mergeable, for: Pnode.Params do
    def merge(earlier, later),
      do: Pnode.Common.merge_parsed(Pnode.Params, earlier, later)
  end

  defimpl Pnode.EENable, for: Pnode.Params do
    def eens(%{eens: eens}), do: eens
    def ensure_eens(node, _default_module) do
      node # Skipped
    end
  end

  defimpl Pnode.Exportable, for: Pnode.Params do
    def export(node), do: Rnode.Params.new(node.parsed)
  end
end


