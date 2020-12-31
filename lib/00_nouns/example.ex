defmodule TransformerTestSupport.Nouns.Example do

  @moduledoc """
  An Example is a plain map because variants may want to add fields to
  it. It might make sense to have a `:variant` field and nest them all
  under it.
  """

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
