defmodule Run.Support.ChangesetFieldsTest do
  use EctoTestDSL.Case
  alias T.Run.ChangesetChecks, as: CC

  test "fields_mentioned" do
    expect = fn checks, expected ->
      assert_good_enough(CC.fields_mentioned(checks), in_any_order(expected))
    end

    [                                 ] |> expect.([          ])
    [:valid,       :other             ] |> expect.([          ])
    [errors: [:a], changed: [:b      ]] |> expect.([:a, :b    ])
    [errors:  :a,  changed: [:b      ]] |> expect.([:a, :b    ])
    [errors:  :a,  changed: [:b, :c  ]] |> expect.([:a, :b, :c])
    [errors:  :a, changed:  [:b, c: 5]] |> expect.([:a, :b, :c])

  end
end 
