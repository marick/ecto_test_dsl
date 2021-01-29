defmodule EctoTestDSL.Parse.ImpliedSetup do
  use EctoTestDSL.Drink.Me
  use Magritte


  def add(named_examples),
    do: named_examples |> KeywordX.map_over_values(&add_setup_required_by_refs/1)

  def add_setup_required_by_refs(example) do
    Map.get(example, :params, [])
    |> FieldRef.relevant_pairs
    |> KeywordX.map_values(fn xref -> {:insert, xref.een} end)
    |> testable__append_to_setup(example, ...)
  end
  
  def testable__append_to_setup(example, new) do
    old = Map.get(example, :setup_instructions, [])

    case {old, new} do
      {_, []} ->
        example
      {[], _} -> 
        Map.put(example, :setup_instructions, new)
      {_, _} ->
        Map.put(example, :setup_instructions, old ++ new)
    end
  end
end
