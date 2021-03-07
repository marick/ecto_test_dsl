defmodule KeyValTest do
  use EctoTestDSL.Case
  alias EctoTestDSL.KeyVal

  test "`filter/reject_by_value` preserves structure, deletes unwanted values" do
    assert KeyVal.filter_by_value( [a: 1, b: "b"], &is_integer/1) == [a: 1]
    assert KeyVal.filter_by_value(%{a: 1, b: "b"}, &is_integer/1) == [a: 1]

    assert KeyVal.reject_by_value( [a: 1, b: "b"], &is_integer/1) == [b: "b"]
    assert KeyVal.reject_by_value(%{a: 1, b: "b"}, &is_integer/1) == [b: "b"]
  end

  test "`filter_by_key` preserves structure, deletes unwanted keys" do
    assert KeyVal.filter_by_key( [a: 1, b: "b"], &(&1 == :a)) == [a: 1]
    assert KeyVal.filter_by_key(%{a: 1, b: "b"}, &(&1 == :a)) == [a: 1]

    assert KeyVal.reject_by_key( [a: 1, b: "b"], &(&1 == :a)) == [b: "b"]
    assert KeyVal.reject_by_key(%{a: 1, b: "b"}, &(&1 == :a)) == [b: "b"]
  end


  test "`fetch_then_map` loses keys, transforms values" do
    assert KeyVal.fetch_then_map([a: 1, b: 2], &(-&1)) == [-1, -2]
    assert KeyVal.fetch_then_map([a: 1, b: 2], &(-&1)) == [-1, -2]
  end

  

end
