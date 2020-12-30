defmodule TransformerTestSupport.Nouns.FieldRef do
  use TransformerTestSupport.Drink.Me

  @moduledoc """
  A reference to a field within an example
  """

  defstruct [:een, :field]
  

  def new([{field, een}]), do: %__MODULE__{een: een, field: field}

  def match?(%__MODULE__{} = _value), do: true
  def match?(_), do: false
end
