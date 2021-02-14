defmodule EctoTestDSL.Run.Node.Params do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  
  @moduledoc """
  """

  defstruct [:params]

  def new(params), do: ~M{%__MODULE__ params}

  def raw(params), do: params.params
end
