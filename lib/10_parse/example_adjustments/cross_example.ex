defmodule TransformerTestSupport.Parse.ExampleAdjustments.CrossExample do
  use TransformerTestSupport.Drink.Me
  use Magritte
  alias T.Parse.Nouns.DeferredParams

  @moduledoc """
  """
  def connect(new_named_examples, existing_named_examples) do
    new_named_examples
    |> Enum.reduce(existing_named_examples, &connect_one/2)
  end

  defp connect_one({new_name, new_example}, existing_named_examples) do
    expanded = 
      new_example
      |> expand_like(existing_named_examples)
      |> add_setup_required_by_refs
    [{new_name, expanded} | existing_named_examples]
  end

  defp expand_like(example, existing_named_examples) do
    resolve = &(DeferredParams.resolve(&1, existing_named_examples))
    Map.update(example, :params, %{}, resolve)
  end

  defp add_setup_required_by_refs(example) do
    Map.get(example, :params, [])
    |> FieldRef.relevant_pairs
    |> KeywordX.map_values(fn xref -> {:insert, xref.een} end)
    |> Example.append_to_setup(example, ...)
  end
end
