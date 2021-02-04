defmodule Parse.NormalizeTest do
  use EctoTestDSL.Case
  alias EctoTestDSL.Parse.Normalize

  test "examples become maps" do
    input = [key: "value", key2: "value 2"]
    assert Normalize.as(:example, input) == %{key: "value", key2: "value 2"}
  end

  test "a flatten list is obeyed" do
    input = [__flatten: [a: 1, b: 2], c: 3, __flatten: [d: 4]]
    expected = %{a: 1, b: 2, c: 3, d: 4}
    assert Normalize.as(:example, input) == expected
  end

  test "note that flattening preserves order for intermediate processing" do
    input = [__flatten: [a: 1, b: 2], c: 3, __flatten: [d: 4]]
    assert Normalize.flatten_keywords(input) == [a: 1, b: 2, c: 3, d: 4]
  end

  test "example pairs" do
    input = [name: [key: [a: 1], other: 2]]
    actual = Normalize.as(:example_pairs, input)
    assert [name: %{key: [a: 1], other: 2}] == actual
  end

end
