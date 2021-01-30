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
  
  test "ensuring eens is pretty much a no-op" do
    params = Node.Params.parse(a: 1, b: id_of(:fred))
    actual = Node.EENable.ensure_eens(params, :ignored)
    assert actual.with_ensured_eens == actual.parsed
    assert Node.EENable.eens(actual) == [een(:fred)]
  end
end
