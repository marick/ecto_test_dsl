defmodule Parse.Node.PreviouslyNodeTest do
  use EctoTestDSL.Case
  alias EctoTestDSL.Parse.Node.Previously
  alias EctoTestDSL.Parse.Node.EENable

  test "creation" do
    expect = fn arg, expected_signifiers ->
      actual = Previously.parse(arg)
      assert actual.signifiers == expected_signifiers
    end

    [insert: :a]                    |> expect.([:a])
    [insert: [:a, :b]]              |> expect.([:a, :b])
    [insert: [:a, b: List]]         |> expect.([:a, {:b, List}])
    [insert: :a, insert: [b: List]] |> expect.([:a, {:b, List}])
    [insert: een(a: Examples)]      |> expect.([een(a: Examples)])

    assertion_fails("`previously` takes arguments of form [insert: <atom>|<list>...]",
      [left: {:inser, :a}],
      fn ->
        Previously.parse([inser: :a])
      end)
  end

  test "merging" do
    one = Previously.new([:a, b: List])
    rest = [ Previously.new([:c]) ]

    actual = EENable.merge(one, rest)
    expected = Previously.new([:a, {:b, List}, :c])
    assert actual == expected
  end

  test "ensuring eens" do
    expect = fn input, expected ->
      Previously.new(input)
      |> EENable.ensure_eens(__MODULE__)
      |> assert_field(eens: expected)
    end

    [:a, b: List]           |> expect.([een(a: __MODULE__), een(b: List)])
    [een(:a), een(b: List)] |> expect.([een(:a, __MODULE__), een(b: List)])
  end

  test "revealing eens" do
    Previously.new([:a, {:b,  List}, een(:c)])
    |> EENable.ensure_eens(__MODULE__)
    |> EENable.eens
    |> assert_equal([een(a: __MODULE__), een(b: List), een(:c)])
  end
end
