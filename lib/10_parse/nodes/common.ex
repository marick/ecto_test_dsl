defmodule EctoTestDSL.Parse.Pnode.Common do
  use EctoTestDSL.Drink.Me
  use T.Drink.Assertively

  def merge_parsed(module, %{parsed: earlier}, %{parsed: later}),
    do: module.new(Map.merge(earlier, later))

  def extract_eens(~M{parsed}), do: extract_een_values(parsed)

  def extract_een_values(kvs) do
    kvs
    |> KeyVal.filter_by_value(&FieldRef.matches?/1)
    |> KeyVal.fetch_map(fn xref -> xref.een end)
  end

  def ensure_one_een(%EEN{} = een, _default_module), do: een
  def ensure_one_een(atom, default_module), do: EEN.new(atom, default_module)

  def with_ensured(node, eens, with_ensured_eens),
    do: %{node | eens: eens, with_ensured_eens: with_ensured_eens}
end

  
