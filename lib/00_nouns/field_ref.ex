defmodule TransformerTestSupport.Nouns.FieldRef do
  use TransformerTestSupport.Drink.Me

  @moduledoc """
  A reference to a field within an example
  """

  defstruct [:een, :field]
  

  def new([{field, een}]), do: %__MODULE__{een: een, field: field}

  def match?(%__MODULE__{} = _value), do: true
  def match?(_), do: false

  def relevant_pairs(pairs), do: KeywordX.filter_by_value(pairs, &match?/1)


  def dereference(%FieldRef{} = ref, in: neighborhood) do
    neighborhood
    |> MapX.fetch!(ref.een, &Messages.missing_een/1)
    |> MapX.fetch!(ref.field, &Messages.missing_key/1)
  end
end
