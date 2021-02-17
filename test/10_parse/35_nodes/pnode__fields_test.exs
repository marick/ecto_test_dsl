defmodule Parse.Pnode.FieldsTest do
  use EctoTestDSL.Case
  alias T.Parse.Pnode
  import T.Parse.InternalFunctions

  test "creation" do
    actual = Pnode.Fields.parse([key: "value"]) 
    assert actual == %Pnode.Fields{parsed: %{key: "value"}}
  end

  test "merging" do
    ab = Pnode.Fields.parse(a: 1, b: 2)
    cd = Pnode.Fields.parse(c: 1, d: 2)
    expected = Pnode.Fields.parse(a: 1, b: 2, c: 1, d: 2)

    assert Pnode.Mergeable.merge(ab, cd) == expected

    # overrides are acceptable
    bc = Pnode.Fields.parse(b: 1, d: 2)
    expected = Pnode.Fields.parse(a: 1, b: 1, d: 2)
    assert Pnode.Mergeable.merge(ab, bc) == expected
  end
  
  test "ensuring eens is pretty much a no-op" do
    params = Pnode.Fields.parse(a: 1, b: id_of(:fred))
    actual = Pnode.EENable.ensure_eens(params, :ignored)
    assert actual.with_ensured_eens == actual.parsed
    assert Pnode.EENable.eens(actual) == [een(:fred)]
  end

  test "export" do
    %Pnode.Fields{with_ensured_eens: %{a: 1, b: id_of(:fred)}}
    |> Pnode.Exportable.export
    |> assert_equal(%{a: 1, b: id_of(:fred)})
  end
end
