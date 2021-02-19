defmodule Neighborhood.ExpandTest do
  use EctoTestDSL.Case
  alias T.Neighborhood.Expand
  import T.Parse.InternalFunctions, only: [id_of: 1]

  test "keyword values" do
    original = %{a: 1}
    neighborhood = %{}
    expected = original
    actual = Expand.values(original, with: neighborhood)
    assert expected == actual
      
    original = %{a: FieldRef.new(id: een(:neighbor))}
    neighborhood = %{een(:neighbor) => %{id: 5}}
    expected = %{a: 5}
    actual = Expand.values(original, with: neighborhood)
    assert expected == actual
  end

  # ----------------------------------------------------------------------------

  test "changeset_checks" do
    checks =   [:valid, changes: [a: 3, b: id_of(:other)]]
    expected = [:valid, changes: [a: 3, b: 3838]]
    actual = Expand.changeset_checks(checks, %{een(:other) => %{id: 3838}})
    assert actual == expected
  end

  test "tested_replace_check_values" do
    expect = fn original, expected ->
      predicate = &is_binary/1
      replacer = &String.upcase/1
      assert Expand.tested_replace_check_values(original, predicate, replacer) == expected
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


  
end
