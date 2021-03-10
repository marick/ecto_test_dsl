defmodule Parse.Pnode.ChangesetChecksTest do
  use EctoTestDSL.Case
  use T.Drink.AndParse
  use T.Parse.Exports
  alias Pnode.ChangesetChecks, as: CC

  describe "creation" do
    defp expect(checks, expected) do
      node = CC.parse(checks)
      assert node.parsed == checks
      assert Pnode.EENable.eens(node) == expected
    end
    
    test "no eens" do
      [changed: [x: 5]] |> expect([])
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

  test "merging" do
    first = CC.parse(changed: [x: 5])
    second = CC.parse(errors: [:x], changed: [y: 8])
    actual = Pnode.Mergeable.merge(first, second)
    assert actual.parsed == [changed: [x: 5], errors: [:x], changed: [y: 8]]
  end

  test "export" do         # also add some top-level tests for merging and eens
    CC.parse(data: [species_id: id_of(:bovine)])
    |> Pnode.Exportable.export
    |> assert_equal(data: [species_id: id_of(:bovine)])
  end
end
