defmodule Impl.NormalizeTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.{Normalize,Like}

  test "params become maps" do
    assert Normalize.as(:params, [a: 1, b: 2]) == %{a: 1, b: 2}
  end

  test "... except that expansions of `__like are left alone" do
    assert Normalize.as(:params, Like.like(:ok)) == Like.like(:ok)
  end

  test "examples become maps of maps" do
    input = [params: [a: 1], other: 2]
    assert Normalize.as(:example, input) == %{params: %{a: 1}, other: 2}
  end

  test "... but examples don't have to have params" do
    input = [other: 2]
    assert Normalize.as(:example, input) == %{other: 2}
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

  test "example pairs may *not* be in a map" do
    input = %{name: [params: [a: 1], other: 2]}
    assertion_fails(
      "Examples must be given in a keyword list (in order for `like/2` to work)",
      fn -> 
        Normalize.as(:example_pairs, input)
      end)
  end
end
