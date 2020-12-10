defmodule TransformerTestSupport.SmartGet.Previously do
  alias TransformerTestSupport, as: T
  import FlowAssertions.Define.BodyParts
  alias T.Messages
    
  @moduledoc """
  """

  def expand_in_list(list, previously) do
    for elt <- list do
      case elt do
        {name, {:__previously_reference, een, :primary_key}} ->
          case Map.get(previously, een) do 
            nil ->
              keys = Map.keys(previously)
              elaborate_flunk(Messages.missing_een(een), right: keys)
            earlier ->
              {name, earlier.id}
          end
        _ -> 
          elt
      end
    end
  end
end
