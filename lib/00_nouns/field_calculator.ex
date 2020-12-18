defmodule TransformerTestSupport.Nouns.FieldCalculator do
  use TransformerTestSupport.Drink.Me

  @moduledoc """
  A description of how a field's value can be calculated in terms of
  other fields (and constants).
  """

  defstruct [:calculation, :args]

  def new(calculation, args), do: %__MODULE__{calculation: calculation, args: args}
end
