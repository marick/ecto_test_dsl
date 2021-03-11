defmodule EctoTestDSL.Run.Rnode.FieldsFrom do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.Assertively
  
  @moduledoc """
  """

  defstruct [:een, :opts]

  def new(een, opts), do: ~M{%__MODULE__ een, opts}
end
