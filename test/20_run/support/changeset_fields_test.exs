defmodule Run.Support.ChangesetFieldsTest do
  use EctoTestDSL.Case
  alias T.Run.ChangesetChecks, as: CC

  test "fields_mentioned" do
    expect = TabularA.run_and_assert(
      &CC.fields_mentioned/1,
      &(assert_good_enough(&1, in_any_order(&2))))
    
    [                                 ] |> expect.([          ])
    [:valid,       :other             ] |> expect.([          ])
    [errors: [:a], changed: [:b      ]] |> expect.([:a, :b    ])
    [errors:  :a,  changed: [:b      ]] |> expect.([:a, :b    ])
    [errors:  :a,  changed: [:b, :c  ]] |> expect.([:a, :b, :c])
    [errors:  :a, changed:  [:b, c: 5]] |> expect.([:a, :b, :c])

  end
end 
