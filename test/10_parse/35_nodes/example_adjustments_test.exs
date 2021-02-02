defmodule Parse.NormalizeTest do
  use EctoTestDSL.Case
  alias EctoTestDSL.Parse.Normalize

  test "params become maps" do
    assert Normalize.as(:params, [a: 1, b: 2]) == %{a: 1, b: 2}
  end

  test "examples become maps of maps" do
    input = [params: [a: 1], other: 2]
    assert Normalize.as(:example, input) == %{params: %{a: 1}, other: 2}
  end

  test "... but examples don't have to have params" do
    input = [other: 2]
    assert Normalize.as(:example, input) == %{other: 2, params: %{}}
  end

  test "a flatten list is obeyed" do
    input = [__flatten: [a: 1, b: 2], c: 3, __flatten: [d: 4]]
    expected = %{a: 1, b: 2, c: 3, d: 4, params: %{}}
    assert Normalize.as(:example, input) == expected
  end

  test "note that flattening preserves order for intermediate processing" do
    # Some keywords are repeated and so handled specially.
    input = [__flatten: [a: 1, b: 2], c: 3, __flatten: [d: 4]]
    assert Normalize.flatten_keywords(input) == [a: 1, b: 2, c: 3, d: 4]
  end

  test "example pair" do
    input = {:name, [params: [a: 1], other: 2]}
    actual = Normalize.as(:example_pair, input)
    assert {:name, %{params: %{a: 1}, other: 2}} == actual
  end

  test "example pairs" do
    input = [name: [params: [a: 1], other: 2]]
    actual = Normalize.as(:example_pairs, input)
    assert [name: %{params: %{a: 1}, other: 2}] == actual
  end

end
