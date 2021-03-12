defmodule EctoTestDSL.Nouns.StructRef do
  use EctoTestDSL.Drink.Me
  alias T.Nouns

  @moduledoc """
  A reference to an entire example
  """

  defstruct [:een, :opts]
  
  def new(een, opts), do: ~M{%__MODULE__ een, opts}

  defimpl Nouns.RefHolder, for: __MODULE__ do
    def eens(_value), do: :wrong

    def dereference(_ref, in: _neighborhood) do
      :wrong
      # neighborhood
      # |> Neighborhood.fetch!(ref.een, :inserted)
      # |> MapX.fetch!(ref.field, &Messages.missing_key/1)
    end
  end

end
