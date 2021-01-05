defmodule TransformerTestSupport.Parse.Nouns.Example do
  use TransformerTestSupport.Drink.Me
  use Magritte

  @moduledoc """
  An Example is a plain map because variants may want to add fields to
  it. It might make sense to have a `:variant` field and nest them all
  under it.
  """

  # ----------------------------------------------------------------------------
  
  def add_setup_required_by_refs(example) do
    Map.get(example, :params, [])
    |> FieldRef.relevant_pairs
    |> KeywordX.map_values(fn xref -> {:insert, xref.een} end)
    |> append_to_setup(example, ...)
  end
  
  def append_to_setup(example, new) do
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
