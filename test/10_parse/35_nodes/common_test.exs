defmodule Parse.Pnode.CommonTest do
  use EctoTestDSL.Case
  use T.Drink.AndParse
  use T.Parse.Exports
  alias Parse.Pnode.Common

  test "extract een values" do
    expect = fn input, expected -> 
      assert_good_enough(
        Common.extract_een_values(input),
        in_any_order(expected))
    end
    
    %{id: 5, age: 3} |> expect.([])
    %{id: 5, other_id: id_of(:v)} |> expect.([een(:v)])
    
    %{id: 5,
      other_id: id_of(:top),
      notes: %{id: 6, other_id: id_of(:lower)}}
      |> expect.([een(:top), een(:lower)])


    %{id: 5,
      other_id: id_of(:top),
      notes: [%{id: 6, other_id: id_of(:lower1)},
              %{id: 7, other_id: id_of(:lower2)}]}
      |> expect.([een(:top), een(:lower1), een(:lower2)])


    %{id: 5,
      other_id: id_of(:top),
      notes: %{"0" => %{id: 6, other_id: id_of(:lower1)},
               "1" => %{id: 7, other_id: id_of(:lower2)},
               "2" => %{id: "", other_id: ""}}}
    |> expect.([een(:top), een(:lower1), een(:lower2)])
  end
end
