defmodule EctoTestDSL.Nouns.StructRef do
  use EctoTestDSL.Drink.Me
  alias T.Parse.Pnode.Common.EENWithOpts
  alias T.Nouns

  @moduledoc """
  A reference to an entire example
  """

  defstruct [:reference_een, :eens, :opts]
  
  def new(een, opts) do 
    EENWithOpts.parse(__MODULE__, een, opts)
  end

  defimpl Nouns.RefHolder, for: __MODULE__ do
    def eens(value), do: value.eens

    def dereference(_ref, in: _neighborhood) do
      :wrong
      # neighborhood
      # |> Neighborhood.fetch!(ref.een, :inserted)
      # |> MapX.fetch!(ref.field, &Messages.missing_key/1)
    end
  end

end
