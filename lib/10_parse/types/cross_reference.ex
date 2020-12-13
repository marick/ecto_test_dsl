defmodule TransformerTestSupport.Parse.Types.CrossReference do
  use TransformerTestSupport.Drink.Me
  import FlowAssertions.Define.BodyParts
  alias T.Messages

  @moduledoc """
  A reference to a field within an example
  """

  # defstruct [:een, :field]
  

  @previously_reference :__previously_reference

  def new(een, use_type),
    do: {@previously_reference, een, use_type}
  
  def xref_t(een, use_type), do: new(een, use_type)

  def cross_reference?(value) do
    is_tuple(value) && elem(value, 0) == @previously_reference
  end
  def cross_reference(_), do: false
  


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
