defmodule Neighborhood.ExpandTest do
  use TransformerTestSupport.Case
  alias T.Neighborhood.Expand

  defp try_params(original, neighborhood, expected) do 
    actual = Expand.params(original, with: neighborhood)
    assert expected == actual
  end
  
  test "params" do
    original = %{a: 1}
    neighborhood = %{}
    expected = original
    try_params(original, neighborhood, expected)
      
    original = %{a: FieldRef.new(id: een(:neighbor))}
    neighborhood = %{een(:neighbor) => %{id: 5}}
    expected = %{a: 5}
    try_params(original, neighborhood, expected)
  end
end
