defmodule EctoTestDSL.Nouns.StructRef do
  use EctoTestDSL.Drink.Me
  alias T.Parse.Pnode.Common.FromPairs
  alias T.Nouns
  import ExUnit.Assertions

  @moduledoc """
  A reference to an entire example
  """

  defstruct [:reference_een, :eens, :except, :ignoring, :only]
  
  def new(reference_een, opts) do 
    except = Keyword.get(opts, :except, []) |> Enum.into(%{})
    eens = [reference_een | FromPairs.extract_een_values(except)]
    ignoring = Keyword.get(opts, :ignoring, [])
    only = Keyword.get(opts, :only, [])

    if not Enum.empty?(ignoring) && not Enum.empty?(only),
    do: flunk("You can't use both `ignoring:` and `only:` when referring to another example")

    ~M{%__MODULE__ reference_een, except, eens, ignoring, only}
  end

  defimpl Nouns.RefHolder, for: __MODULE__ do
    def eens(value), do: value.eens

    def dereference(ref, in: neighborhood) do
      base = Neighborhood.fetch!(neighborhood, ref.reference_een, :params)
      filtered = 
        case {ref.only, ref.ignoring} do
          {[  ], [    ]} -> base
          {[  ], ignore} -> Map.drop(base, ignore)
          {only, [    ]} -> Map.take(base, only)
        end

      Map.merge(filtered, 
        Neighborhood.Expand.values(ref.except, with: neighborhood))
    end
  end
end
