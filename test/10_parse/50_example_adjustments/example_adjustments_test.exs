defmodule Parse.ExampleAdjustmentsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Parse.ExampleAdjustments

  test "params become maps" do
    assert ExampleAdjustments.adjust(:params, [a: 1, b: 2]) == %{a: 1, b: 2}
  end

  test "examples become maps of maps" do
    input = [params: [a: 1], other: 2]
    assert ExampleAdjustments.adjust(:example, input) == %{params: %{a: 1}, other: 2}
  end

  test "... but examples don't have to have params" do
    input = [other: 2]
    assert ExampleAdjustments.adjust(:example, input) == %{other: 2, params: %{}}
  end

  test "a flatten list is obeyed" do
    input = [__flatten: [a: 1, b: 2], c: 3, __flatten: [d: 4]]
    expected = %{a: 1, b: 2, c: 3, d: 4, params: %{}}
    assert ExampleAdjustments.adjust(:example, input) == expected
  end

  test "note that flattening preserves order for intermediate processing" do
    # Some keywords are repeated and so handled specially.
    input = [__flatten: [a: 1, b: 2], c: 3, __flatten: [d: 4]]
    assert ExampleAdjustments.flatten_keywords(input) == [a: 1, b: 2, c: 3, d: 4]
  end

  test "example pair" do
    input = {:name, [params: [a: 1], other: 2]}
    actual = ExampleAdjustments.adjust(:example_pair, input)
    assert {:name, %{params: %{a: 1}, other: 2}} == actual
  end

  test "example pairs" do
    input = [name: [params: [a: 1], other: 2]]
    actual = ExampleAdjustments.adjust(:example_pairs, input)
    assert [name: %{params: %{a: 1}, other: 2}] == actual
  end

end
