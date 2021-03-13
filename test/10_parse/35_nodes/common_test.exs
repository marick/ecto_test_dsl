defmodule Parse.Pnode.CommonTest do
  use EctoTestDSL.Case
  use T.Drink.AndParse
  use T.Parse.Exports
  alias Parse.Pnode.Common

  describe "FromPairs" do
    defp expect(input, expected) do 
      assert_good_enough(
        Common.FromPairs.extract_een_values(input),
        in_any_order(expected))
    end
    
    test "extract een values - simple" do
      %{id: 5, age: 3} |> expect([])
      %{id: 5, other_id: id_of(:v)} |> expect([een(:v)])
    end

    test "recursive map (typically an association)" do 
      %{id: 5,
        other_id: id_of(:top),
        note: %{id: 6, other_id: id_of(:lower)}}
      |> expect([een(:top), een(:lower)])
    end
      
    test "a list of nested structures (as with has-many, for example)" do 
      %{id: 5,
        other_id: id_of(:top),
        notes: [%{id: 6, other_id: id_of(:lower1)},
                %{id: 7, other_id: id_of(:lower2)}]}
      |> expect([een(:top), een(:lower1), een(:lower2)])
    end

    test "a list that does not contain structures" do
      %{notes: [1, id_of(:two), 3]}
      |> expect([een(:two)])
    end

    test "a format sometimes created for a list of structures" do 
      %{id: 5,
        other_id: id_of(:top),
        notes: %{"0" => %{id: 6, other_id: id_of(:lower1)},
                 "1" => %{id: 7, other_id: id_of(:lower2)},
                 "2" => %{id: "", other_id: ""}}}
      |> expect([een(:top), een(:lower1), een(:lower2)])
    end


    # ----------------------------------------------------------------------------

    test "merging" do
      one = Pnode.Params.parse(id1: id_of(:id1), override: 1)
      two = Pnode.Params.parse(id2: id_of(:id2), override: 2, extra: 3)

      Common.FromPairs.merge(Pnode.Params, one, two)
      |> assert_fields(parsed: %{id1: id_of(:id1), id2: id_of(:id2), override: 2, extra: 3},
                       eens: in_any_order([een(:id1), een(:id2)]))
    end
  end

  
end
