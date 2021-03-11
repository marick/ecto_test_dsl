defmodule EctoTestDSL.Parse.Pnode.Previously do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively
  alias Pnode.Previously, as: This
  
  defstruct [:eens]

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

  def new(parsed) do
    eens = extract_eens(parsed)
    %__MODULE__{eens: eens}
  end

  defp extract_eens(parsed) do
    default_module = BuildState.examples_module
    one = fn
      {name, module} -> EEN.new(name, module)
      %EEN{} = een  -> een
      name           -> EEN.new(name, default_module)
    end

    Enum.map(parsed, one)
  end
  

  defimpl Pnode.Mergeable, for: This do
    def merge(one, two) do
      [one, two]
      |> Enum.map(&(&1.eens))
      |> Enum.concat
      |> This.new
    end
  end

  defimpl Pnode.EENable, for: This do
    def eens(%{eens: eens}), do: eens
  end

  defimpl Pnode.Deletable, for: This do
  def a_protocol_must_have_at_least_one_function(_node),
      do: raise "should never be called"
  end
end
