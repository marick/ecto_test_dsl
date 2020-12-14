defmodule Link.ReplaceTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  alias T.Parse.CrossReference
  import T.Build
  alias T.Link.Replace

  @example_has_5 %{een_t(:example) => %{id: 5}}

  test "any_cross_reference_values success cases" do
    expect = fn [list, previously], expected ->
      assert Replace.any_cross_reference_values(list, previously) == expected
    end

    [ [    ], %{                      } ] |> expect.([    ])
    [ [a: 5], %{                      } ] |> expect.([a: 5])
    [ [a: 5], %{een_t(:example) => "..."} ] |> expect.([a: 5])

    [ [a: id_of(:example)], @example_has_5] |> expect.([a: 5])

    [ [:z, {:a, id_of(:example)}], @example_has_5] |> expect.([:z, {:a, 5}])
  end

  test "any_cross_reference_values failure" do
    assertion_fails("There is no example named `:examp` in ReplaceTest",
      fn ->
        Replace.any_cross_reference_values([a: id_of(:examp)], @example_has_5)
      end)
  end
end 
