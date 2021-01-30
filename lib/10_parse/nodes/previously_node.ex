defmodule EctoTestDSL.Parse.Node.Previously do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias T.Parse.Node
  use Magritte
  
  defstruct [:parsed, :with_ensured_eens, :eens]

  def parse(kws) do
    kws
    |> Enum.reduce([], &parse_one/2)
    |> new
  end

  defp parse_one({:insert, atom}, acc) when is_atom(atom),
    do: parse_one({:insert, [atom]}, acc)
  defp parse_one({:insert, %EEN{} = een}, acc),
    do: parse_one({:insert, [een]}, acc)
  defp parse_one({:insert, list}, acc) when is_list(list),
    do: acc ++ list
  defp parse_one(wrong, _acc) do
    elaborate_flunk(
      "`previously` takes arguments of form [insert: <atom>|<list>...]",
      left: wrong)
  end    

  def new(parsed), do: %__MODULE__{parsed: parsed}

  defimpl Node.EENable, for: Node.Previously do
    def merge(one, more) do
      [one | more]
      |> Enum.map(&(&1.parsed))
      |> Enum.concat
      |> Node.Previously.new
    end

    def eens(%{eens: eens}), do: eens

    def ensure_eens(node, default_module) do
      ensure_one = fn
        {name, module} -> EEN.new(name, module)
        %EEN{} = een  -> een
        name           -> EEN.new(name, default_module)
      end

      ensured = Enum.map(node.parsed, ensure_one)
      %{node | with_ensured_eens: ensured, eens: ensured}
    end
  end
end


