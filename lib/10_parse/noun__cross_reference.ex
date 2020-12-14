defmodule TransformerTestSupport.Parse.CrossReference do
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
end
