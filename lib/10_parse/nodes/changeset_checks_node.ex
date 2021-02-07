defmodule EctoTestDSL.Parse.Node.ChangesetChecks do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias T.Parse.Node
  alias Node.ChangesetChecks, as: CC
  use Magritte
  
  defstruct parsed: [], with_ensured_eens: [], eens: []

  def parse(kws), do: new(kws)
  def new(kws), do: %CC{parsed: kws}

  defimpl Node.Mergeable, for: CC do
    def merge(%CC{parsed: earlier}, %CC{parsed: later}) do
      # I actually do mean this rather than Keyword.merge
      CC.new(earlier ++ later)
    end
  end

  defimpl Node.EENable, for: CC do
    def eens(%{eens: eens}), do: eens

    def ensure_eens(node, _default_module) do
      eens = Enum.flat_map(node.parsed, &top_level/1)
      %{node | eens: eens, with_ensured_eens: node.parsed}
    end

    defp top_level({_top_key, next_level}) when is_list(next_level),
      do: Enum.flat_map(next_level, &lower_level/1)
    defp top_level({_top_key, ~M(%FieldRef een)}), do: [een]
    defp top_level({_top_key, _some_value      }), do: [   ]
    
    defp lower_level({_lower_key, ~M(%FieldRef een)}), do: [een]
    defp lower_level({_lower_key, _value}),            do: [   ]
    defp lower_level(~M(%FieldRef een)   ),            do: [een]
    defp lower_level(_value              ),            do: [   ]
  end

  defimpl Node.Exportable, for: CC do
    def export(node) do
      node.with_ensured_eens
    end
  end
end


