defmodule EctoTestDSL.Parse.Pnode.ChangesetChecks do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  alias Pnode.ChangesetChecks, as: CC
  
  defstruct parsed: [], eens: []

  def parse(kws), do: new(kws)
  def new(kws) do
    %CC{parsed: kws,
        eens: Enum.flat_map(kws, &top_level/1)}
  end

  defp top_level({_top_key, next_level}) when is_list(next_level),
    do: Enum.flat_map(next_level, &lower_level/1)
  defp top_level({_top_key, ~M(%FieldRef een)}), do: [een]
  defp top_level({_top_key, _some_value      }), do: [   ]
  
  defp lower_level({_lower_key, ~M(%FieldRef een)}), do: [een]
  defp lower_level({_lower_key, _value}),            do: [   ]
  defp lower_level(~M(%FieldRef een)   ),            do: [een]
  defp lower_level(_value              ),            do: [   ]

  defimpl Pnode.Mergeable, for: CC do
    def merge(%CC{parsed: earlier}, %CC{parsed: later}) do
      # I actually do mean this rather than Keyword.merge
      CC.new(earlier ++ later)
    end
  end

  defimpl Pnode.EENable, for: CC do
    def eens(%{eens: eens}), do: eens

    def ensure_eens(node, _default_module) do
      node
    end
  end

  defimpl Pnode.Exportable, for: CC do
    def export(node) do
      node.parsed
    end
  end
end


