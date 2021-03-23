defmodule EctoTestDSL.Nouns.AsCast do
  use EctoTestDSL.Drink.Me
  alias T.Nouns.AsCast


  # This has gotten fairly pointless as an independent structure
  # Rename?

  @moduledoc """
  A reference to schema fields.
  """

  defstruct [:field_names]

  def new(field_names), do: ~M{%AsCast field_names}
  def nothing(), do: new([])

  def merge(%AsCast{field_names: first}, %AsCast{field_names: second}),
    do: new(first ++ second)

  def subtract(~M{%AsCast field_names}, names),
    do: field_names |> EnumX.difference(names) |> new

end
