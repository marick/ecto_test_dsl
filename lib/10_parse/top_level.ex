defmodule TransformerTestSupport.Parse.TopLevel do
  use TransformerTestSupport.Drink.Me
  # alias T.Build.{Normalize,ParamShorthand,KeyValidation}
  import DeepMerge, only: [deep_merge: 2]
  # import FlowAssertions.Define.BodyParts
  # alias T.Nouns.{FieldCalculator,AsCast}

  def propagate_metadata(test_data) do
    metadata = Map.delete(test_data, :examples) # Let's not have a recursive structure.
    new_examples = 
      for {name, example} <- test_data.examples do
        {name, deep_merge(example, %{metadata: metadata})}
      end
    Map.put(test_data, :examples, new_examples)
  end
  
end
