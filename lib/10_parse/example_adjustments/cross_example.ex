defmodule TransformerTestSupport.Parse.ExampleAdjustments.CrossExample do
  use TransformerTestSupport.Drink.Me
  alias T.Parse.Nouns.Example

  @moduledoc """
  """
  def expand_likes(new_named_examples, existing_named_examples) do
    starting_acc = %{expanded: [], existing: existing_named_examples}

    reducer = fn {new_name, new_example}, acc ->
      # Should write a map_second
      better =
        {new_name, Example.expand_like(new_example, acc.existing)}

      %{expanded: [better | acc.expanded ], existing: [better | acc.existing]}
    end

    Enum.reduce(new_named_examples, starting_acc, reducer).expanded
  end
end
