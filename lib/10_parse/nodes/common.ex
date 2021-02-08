defmodule EctoTestDSL.Parse.Node.Common do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice

  def merge_parsed(module, %{parsed: earlier}, %{parsed: later}),
    do: module.new(Map.merge(earlier, later))

  def extract_eens(~M{parsed}) do
    parsed
    |> FieldRef.relevant_pairs
    |> KeyVal.fetch_map(fn xref -> xref.een end)
  end

  def ensure_eens(node) do
    eens = extract_eens(node)
    %{node | eens: eens, with_ensured_eens: node.parsed}
  end
  
end

  
