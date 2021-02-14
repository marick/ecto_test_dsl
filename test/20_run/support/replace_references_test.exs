defmodule Run.Support.ReplaceReferencesTest do
  use EctoTestDSL.Case
  import T.Run.ChangesetChecks
  use T.Parse.Exports

  # ----------------------------------------------------------------------------

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
