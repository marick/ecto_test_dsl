defmodule Nouns.StructRefTest do
  use EctoTestDSL.Case
  alias T.Nouns.RefHolder
  use T.Parse.Exports

  test "creation" do
    ref_een = een(example_name: Examples)

    ref = StructRef.new(ref_een, except: [b_id: id_of(:b)])

    assert_fields(ref, reference_een: ref_een, opts: [except: [b_id: id_of(:b)]])
    assert_good_enough(RefHolder.eens(ref), in_any_order([ref_een, een(:b)]))
  end


  describe "dereference" do
    test "simple case" do
      neighborhood = %{
        een(:een) => Neighborhood.Value.params(%{a: 5})
      }
      ref = StructRef.new(een(:een), [])

      RefHolder.dereference(ref, in: neighborhood)
      |> assert_equal(%{a: 5})
    end
  end
end 
