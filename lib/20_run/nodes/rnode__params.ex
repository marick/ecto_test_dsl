defmodule EctoTestDSL.Run.Rnode.Params do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndRun
  use T.Drink.Assertively
  alias T.Run.Rnode
  
  @moduledoc """
  """

  defstruct [:params]

  def new(params), do: ~M{%__MODULE__ params}

  def raw(params), do: params.params

  defimpl Rnode.Substitutable, for: Rnode.Params do
    def substitute(%{params: params}, neighborhood) do
      Neighborhood.Expand.values(params, with: neighborhood)
    end
  end
  
end


