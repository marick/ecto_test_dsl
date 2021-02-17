defmodule EctoTestDSL.Run.Rnode.FieldsLike do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  
  @moduledoc """
  """

  defstruct [:een, :opts]

  def new(een, opts), do: ~M{%__MODULE__ een, opts}
end
