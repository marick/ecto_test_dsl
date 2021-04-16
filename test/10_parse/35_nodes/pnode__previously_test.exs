defmodule Parse.Pnode.PreviouslyTest do
  use EctoTestDSL.Case
  alias T.Parse.Pnode
  alias T.Parse.BuildState

  setup do
    BuildState.put(%{examples_module: Examples})
    :ok
  end

  test "creation" do
    expect = TabularA.run_and_assert(
      &(Pnode.Previously.parse(&1) |> Pnode.EENable.eens))

    [insert:  :a                  ] |> expect.([een(a: Examples)])
    [insert: [:a, :b      ]       ] |> expect.([een(a: Examples), een(b: Examples)])
    [insert: [:a,  b: List]       ] |> expect.([een(a: Examples), een(b: List)])

    [insert: :a, insert: [b: List]] |> expect.([een(a: Examples), een(b: List)])
    
    [insert: een(a: Examples)     ] |> expect.([een(a: Examples)])

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
end
