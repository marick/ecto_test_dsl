defmodule Link.ManipulateChangesetChecksTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  import T.Link.ManipulateChangesetChecks
  import T.Build

  test "replace_check_values" do
    expect = fn original, expected ->
      predicate = &is_binary/1
      replacer = &String.upcase/1
      assert replace_check_values(original, predicate, replacer) == expected
    end

    unchanged = fn original -> original |> expect.(original) end

    unchanged.([:valid])
    unchanged.([:valid,
                changes: [a: 3, b: 4],
                changes: [:a, :b],
                change: :a,
                error_free: [:a, :b]])

    [changes: [a: 3, b: "four"]] |> expect.([changes: [a: 3, b: "FOUR"]])
  end

  test "replace_fieldrefs" do
    checks =   [:valid, changes: [a: 3, b: id_of(:other)]]
    expected = [:valid, changes: [a: 3, b: 3838]]
    actual = replace_field_refs(checks, %{een(:other) => %{id: 3838}})
    assert actual == expected
  end
end
