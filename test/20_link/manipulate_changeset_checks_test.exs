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



  test "unique_fields" do
    expect = fn changeset_checks, expected ->
      actual = unique_fields(changeset_checks)
      assert actual == expected
    end
    
    # Handling of lone symbols
    [change: :a            ] |> expect.([:a])
    [change: :a, change: :b] |> expect.([:a, :b])
    [change: :a, error:  :a] |> expect.([:a])

    # Handling of embedded lists
    [change: :a, changes: [:b, :c]] |> expect.([:a, :b, :c])
    [change: :a, error:  [:a, :b]] |> expect.([:a, :b])
    
    # Handling of embedded keyword lists
    [change: :a, changes: [b: 3, c: 4]] |> expect.([:a, :b, :c])
    [change: :a, errors:  [a: "message"]] |> expect.([:a])
    
    # Is not fooled by single-element (global) checks
    [:valid, change: :a    ] |> expect.([:a])
  end
  
  
end
