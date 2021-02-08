defmodule EctoTestDSL.Nouns.FieldRef do
  use EctoTestDSL.Drink.Me

  @moduledoc """
  A reference to a field within an example
  """

  defstruct [:een, :field]
  

  def new([{field, een}]), do: %__MODULE__{een: een, field: field}

  def matches?(value), do: match?(%FieldRef{}, value)

  def dereference(%FieldRef{} = ref, in: neighborhood) do
    neighborhood
    |> MapX.fetch!(ref.een, &Messages.missing_een/1)
    |> MapX.fetch!(ref.field, &Messages.missing_key/1)
  end
end
