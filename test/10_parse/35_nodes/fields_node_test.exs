defmodule Parse.Node.FieldsNodeTest do
  use EctoTestDSL.Case
  alias T.Parse.Node
  import T.Parse.InternalFunctions

  test "creation" do
    actual = Node.Fields.parse([key: "value"]) 
    assert actual == %Node.Fields{parsed: %{key: "value"}}
  end

  test "merging" do
    ab = Node.Fields.parse(a: 1, b: 2)
    cd = Node.Fields.parse(c: 1, d: 2)
    expected = Node.Fields.parse(a: 1, b: 2, c: 1, d: 2)

    assert Node.Mergeable.merge(ab, cd) == expected

    # overrides are acceptable
    bc = Node.Fields.parse(b: 1, d: 2)
    expected = Node.Fields.parse(a: 1, b: 1, d: 2)
    assert Node.Mergeable.merge(ab, bc) == expected
  end
  
  test "ensuring eens is pretty much a no-op" do
    params = Node.Fields.parse(a: 1, b: id_of(:fred))
    actual = Node.EENable.ensure_eens(params, :ignored)
    assert actual.with_ensured_eens == actual.parsed
    assert Node.EENable.eens(actual) == [een(:fred)]
  end

  test "export" do
    %Node.Fields{with_ensured_eens: %{a: 1, b: id_of(:fred)}}
    |> Node.Exportable.export
    |> assert_equal(%{a: 1, b: id_of(:fred)})
  end
end
