defmodule Parse.Node.PreviouslyNodeTest do
  use EctoTestDSL.Case
  alias EctoTestDSL.Parse.Node.Previously
  alias EctoTestDSL.Parse.Node.EENable

  test "creation" do
    expect = fn arg, expected_parsed ->
      actual = Previously.parse(arg)
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
    run = fn input ->
      Previously.new(input)
      |> EENable.ensure_eens(SomeModule)
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
