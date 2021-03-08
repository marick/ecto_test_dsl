defmodule EctoTestDSL.Run.Rnode.ParamsFromRepo do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndRun
  use T.Drink.Assertively
  alias T.Run.Rnode
  
  @moduledoc """
  """

  defstruct [:een, :except]

  def new(een, except), do: ~M{%__MODULE__ een, except}

  defimpl Rnode.Substitutable, for: Rnode.ParamsFromRepo do
    def substitute(node, neighborhood) do
      base = Neighborhood.fetch!(neighborhood, node.een, :inserted) |> Map.from_struct
      exceptions = Neighborhood.Expand.values(node.except, with: neighborhood)
      Map.merge(base, exceptions)
    end
  end
end
