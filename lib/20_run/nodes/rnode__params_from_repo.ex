defmodule EctoTestDSL.Run.Rnode.ParamsFromRepo do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndRun
  use T.Drink.AssertionJuice
  alias T.Run.Rnode
  
  @moduledoc """
  """

  defstruct [:een, :except]

  def new(een, except), do: ~M{%__MODULE__ een, except}

  # defimpl Rnode.Substitutable, for: Rnode.Params do
  #   def substitute(%{params: params}, neighborhood) do
  #     Neighborhood.Expand.keyword_values(params, with: neighborhood)
  #   end
  # end
end


