defmodule TransformerTestSupport.Nouns.FieldCalculator do
  use TransformerTestSupport.Drink.Me
  import FlowAssertions.Define.BodyParts
  
  @moduledoc """
  A description of how a field's value can be calculated in terms of
  other fields (and constants).
  """

  defstruct [:calculation, :args]

  def new(calculation, args), do: %__MODULE__{calculation: calculation, args: args}

  def merge(kws1, kws2) do
    on_duplicate_key = fn field, val1, val2 ->
      elaborate_assert(val1 == val2, 
        merge_error(field),
        left: val1, right: val2)
      val1
    end
    
    Keyword.merge(kws1, kws2, on_duplicate_key)
  end

  def merge_error(field),
    do: "You gave field `#{inspect field}` two different values"

end
