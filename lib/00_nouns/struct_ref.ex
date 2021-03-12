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

    def dereference(ref, in: neighborhood) do
      neighborhood
      |> Neighborhood.fetch!(ref.reference_een, :params)
    end
  end

end
