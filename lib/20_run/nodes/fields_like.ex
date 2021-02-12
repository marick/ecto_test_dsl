defmodule EctoTestDSL.Run.Node.FieldsLike do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  alias T.Parse.Node
  
  @moduledoc """
  """

  defstruct [:een, :opts]

  def new(een, opts), do: ~M{%__MODULE__ een, opts}
end
