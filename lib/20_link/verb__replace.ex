defmodule TransformerTestSupport.Link.Replace do
  use TransformerTestSupport.Drink.Me
  import FlowAssertions.Define.BodyParts
  alias T.Messages

  def any_cross_reference_values(list, inserted_examples) do
    for elt <- list do
      case elt do
        {name, %FieldRef{een: een, field: field}} ->
          case Map.get(inserted_examples, een) do 
            nil ->
              keys = Map.keys(inserted_examples)
              elaborate_flunk(Messages.missing_een(een), right: keys)
            earlier ->
              {name, Map.get(earlier, field)}
          end
        _ -> 
          elt
      end
    end
  end
  
end
