defmodule Parse.ExampleFunctions.ParamsTest do
  use EctoTestDSL.Case
  use T.Drink.AndParse
  use T.Parse.Exports

  describe "creation" do 
    test "without eens" do
      assert params(id: 5, age: 3) == {:params, Pnode.Params.parse(%{id: 5, age: 3})}
    end

    test "with eens" do
      input = [id: 5, other_id: id_of(:other)]
      expected = %{id: 5, other_id: id_of(:other)}
      assert params(input) == {:params, Pnode.Params.parse(expected)}
    end
  end    

end
