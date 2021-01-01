defmodule TransformerTestSupport.Parse.ExampleAdjustments.CrossExample do
  use TransformerTestSupport.Drink.Me
  use Magritte
  alias T.Parse.Nouns.DeferredParams

  @moduledoc """
  """
  def connect(new_named_examples, existing_named_examples) do
    processed = 
      expand_likes(new_named_examples, [], existing_named_examples)
      |> KeywordX.map_over_values(&add_setup_required_by_refs/1)

    processed ++ existing_named_examples
  end

  defp expand_likes([{new_name, new_example} | rest], acc, existing_named_examples) do
    expanded = 
      new_example
      |> expand_like(existing_named_examples)
    new = {new_name, expanded}
    
    expand_likes(rest, [new | acc ], [new | existing_named_examples])
  end

  defp expand_likes([], acc, _existing_named_examples), do: acc

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
