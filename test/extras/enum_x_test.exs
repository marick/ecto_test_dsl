defmodule EnumXTest do
  use TransformerTestSupport.Drink.Me
  use ExUnit.Case

  describe "take_until" do
    test "doesn't stop" do
      assert [1, 2, 3] == EnumX.take_until([1, 2, 3], fn _ -> false end)
    end

    test "does stop" do
      assert [1, 2] == EnumX.take_until([1, 2, 3], &(&1 == 2))
    end
  end


  test "difference" do 
    expect = fn {first, second}, expected ->
      actual = EnumX.difference(first, second)
      assert actual == expected
    end
    
    # Base cases.
    {  [],        [  ] } |> expect.([  ])
    {  [],        [:b] } |> expect.([  ])
    {  [:a],      [  ] } |> expect.([:a])
    {  [:a],      [:a] } |> expect.([  ])
    {  [:a, :b],  [:a] } |> expect.([:b])

    # duplicates
    {  [:a, :b, :a], [:a    ] } |> expect.([:b])
    {  [:a        ], [:a, :a] } |> expect.([ ])

    # Note that duplicates can be retained
    {  [:b, :b      ], [:a, :a] } |> expect.([:b, :b])
  end

  
end
