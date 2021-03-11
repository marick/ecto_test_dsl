defmodule EctoTestDSL.Nouns.FieldRef do
  use EctoTestDSL.Drink.Me
  alias T.Nouns

  @moduledoc """
  A reference to a field within an example
  """

  defstruct [:een, :field]
  

  def new([{field, een}]), do: %__MODULE__{een: een, field: field}

  defimpl Nouns.RefHolder, for: __MODULE__ do
    def eens(value), do: [value.een]

    def dereference(ref, in: neighborhood) do
      neighborhood
      |> Neighborhood.fetch!(ref.een, :inserted)
      |> MapX.fetch!(ref.field, &Messages.missing_key/1)
    end
  end

end
