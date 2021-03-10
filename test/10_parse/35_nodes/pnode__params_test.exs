defmodule Parse.Pnode.ParamsTest do
  use EctoTestDSL.Case
  use T.Drink.AndParse
  use T.Parse.Exports

  test "creation" do
    actual = Pnode.Params.parse([key: "value"]) 
    assert actual == %Pnode.Params{parsed: %{key: "value"}}
  end

  test "merging" do
    ab = Pnode.Params.parse(a: 1, b: 2)
    cd = Pnode.Params.parse(c: 1, d: 2)
    expected = Pnode.Params.parse(a: 1, b: 2, c: 1, d: 2)

    assert Pnode.Mergeable.merge(ab, cd) == expected

    # overrides are acceptable
    bc = Pnode.Params.parse(b: 1, d: 2)
    expected = Pnode.Params.parse(a: 1, b: 1, d: 2)
    assert Pnode.Mergeable.merge(ab, bc) == expected
  end
  
  test "ensuring eens is pretty much a no-op" do
    params = Pnode.Params.parse(a: 1, b: id_of(:fred))
    assert Pnode.EENable.eens(params) == [een(:fred)]
  end

  test "export" do
    Pnode.Params.parse(a: 1, b: id_of(:fred))
    |> Pnode.Exportable.export
    |> Rnode.Params.raw
    |> assert_equal(%{a: 1, b: id_of(:fred)})
  end

end
