defmodule Parse.Pnode.PreviouslyTest do
  use EctoTestDSL.Case
  alias EctoTestDSL.Parse.Pnode

  test "creation" do
    expect = fn arg, expected_parsed ->
      actual = Pnode.Previously.parse(arg)
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
        Pnode.Previously.parse([inser: :a])
      end)
  end

  test "merging" do
    one = Pnode.Previously.new([:a, b: List])
    two = Pnode.Previously.new([:c])

    actual = Pnode.Mergeable.merge(one, two)
    expected = Pnode.Previously.new([:a, {:b, List}, :c])
    assert actual == expected
  end


  
  test "ensuring eens" do
    run = fn input ->
      Pnode.Previously.new(input)
      |> Pnode.EENable.ensure_eens(SomeModule)
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
