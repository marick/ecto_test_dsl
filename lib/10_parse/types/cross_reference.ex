defmodule TransformerTestSupport.Parse.Types.CrossReference do
  use TransformerTestSupport.Drink.Me
  import FlowAssertions.Define.BodyParts
  alias T.Messages

  @moduledoc """
  A reference to a field within an example
  """

  defstruct [:een, :field]
  

  def new(een, field), do: %__MODULE__{een: een, field: field}
  def xref_t(een, field), do: new(een, field)

  def cross_reference?(%__MODULE__{} = _value), do: true
  def cross_reference?(_), do: false

  def expand_in_list(list, previously) do
    for elt <- list do
      case elt do
        {name, %__MODULE__{een: een, field: field}} ->
          case Map.get(previously, een) do 
            nil ->
              keys = Map.keys(previously)
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
