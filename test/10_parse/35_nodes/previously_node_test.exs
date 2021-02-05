defmodule Parse.Node.PreviouslyNodeTest do
  use EctoTestDSL.Case
  alias EctoTestDSL.Parse.Node
  alias EctoTestDSL.Parse.Node

  test "creation" do
    expect = fn arg, expected_parsed ->
      actual = Node.Previously.parse(arg)
      assert actual.parsed == expected_parsed
    end

    [insert: :a]                    |> expect.([:a])
    [insert: [:a, :b]]              |> expect.([:a, :b])
    [insert: [:a, b: List]]         |> expect.([:a, {:b, List}])
    [insert: :a, insert: [b: List]] |> expect.([:a, {:b, List}])
    [insert: een(a: Examples)]      |> expect.([een(a: Examples)])

    assertion_fails("`previously` takes arguments of form [insert: <atom>|<list>...]",
      [left: {:inser, :a}],
      fn ->
        Node.Previously.parse([inser: :a])
      end)
  end

  test "merging" do
    one = Node.Previously.new([:a, b: List])
    two = Node.Previously.new([:c])

    actual = Node.Mergeable.merge(one, two)
    expected = Node.Previously.new([:a, {:b, List}, :c])
    assert actual == expected
  end


  
  test "ensuring eens" do
    run = fn input ->
      Node.Previously.new(input)
      |> Node.EENable.ensure_eens(SomeModule)
    end

    actual = run.([:a, b: List])
    expected = [een(a: SomeModule), een(b: List)]
    assert actual.with_ensured_eens == expected
    assert actual.eens == expected

    actual = run.([een(:a), een(b: List)])
    expected = [een(a: __MODULE__), een(b: List)]
    assert actual.with_ensured_eens == expected
    assert actual.eens == expected
  end
end
