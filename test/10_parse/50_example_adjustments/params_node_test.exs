defmodule Parse.Node.ParamsNodeTest do
  use EctoTestDSL.Case
  alias T.Parse.Node
  import T.Parse.InternalFunctions

  test "creation" do
    assert Node.Params.parse(:anything) == %Node.Params{parsed: :anything}
  end

  test "merging" do
    ab = Node.Params.parse(a: 1, b: 2)
    cd = Node.Params.parse(c: 1, d: 2)
    expected = Node.Params.parse(a: 1, b: 2, c: 1, d: 2)

    assert Node.EENable.merge(ab, cd) == expected

    # overrides are acceptable
    bc = Node.Params.parse(b: 1, d: 2)
    expected = Node.Params.parse(a: 1, b: 1, d: 2)
    assert Node.EENable.merge(ab, bc) == expected
  end
  
  test "ensuring eens makes no changes" do
    params = Node.Params.parse(a: 1, b: id_of(:fred))
    actual = Node.EENable.ensure_eens(params, :ignored)
    assert actual.parsed == params.parsed
  end

  test "revealing eens" do
    actual = 
      Node.Params.parse(a: 1, b: id_of(:fred))
      |> Node.EENable.ensure_eens(:ignored_module)
      |> Node.EENable.eens
    assert actual == [een(fred: __MODULE__)]
  end
end
