defmodule EctoTestDSL.Parse.Pnode.ChangesetChecks do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  alias Pnode.ChangesetChecks, as: This
  
  
  defstruct parsed: [], eens: []

  def parse(kws), do: new(kws)
  def new(kws) do
    %This{parsed: kws,
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

  defimpl Pnode.Mergeable, for: This do
    def merge(earlier, %This{} = later) do
      # I actually do mean this rather than Keyword.merge
      %This{
        parsed: earlier.parsed ++ later.parsed,
        eens: earlier.eens ++ later.eens
      }
    end
  end

  defimpl Pnode.EENable, for: This do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Exportable, for: This do
    def export(node) do
      node.parsed
    end
  end
end


