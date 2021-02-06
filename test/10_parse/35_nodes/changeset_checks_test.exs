defmodule Parse.Node.ChangesetChecksTest do
  use EctoTestDSL.Case
  alias T.Parse.Node
  alias Node.ChangesetChecks, as: CC
  import T.Parse.InternalFunctions

  test "creation" do
    actual = CC.parse(changed: [x: 5])
    assert actual.parsed == [changed: [x: 5]]
  end

  test "merging" do
    first = CC.parse(changed: [x: 5])
    second = CC.parse(errors: [:x], changed: [y: 8])
    actual = Node.Mergeable.merge(first, second)
    assert actual.parsed == [changed: [x: 5], errors: [:x], changed: [y: 8]]
  end

  describe "een handling" do
    defp expect(checks, expected) do
      node = CC.parse(checks)
      actual = Node.EENable.ensure_eens(node, :ignored)
      assert actual.with_ensured_eens == node.parsed
      assert Node.EENable.eens(actual) == expected
    end
    
    test "makes no changes eens does nothing, since `id_of` produces true eens" do
      [changed: [x: 5], changed: [y: id_of(:example)]] |> expect([een(:example)])
    end

    test "top-level keys that don't have lists as values" do
      [errorful: :x]              |> expect([             ])
      [errorful: id_of(:example)] |> expect([een(:example)])
    end

    test "lower-level lists need not be true keyword lists" do 
      [changed: [:x, y: 5]] |> expect([])
      [changed: [id_of(:one), y: id_of(:two)]] |> expect([een(:one), een(:two)])
    end
  end

  test "export" do
  end

end
