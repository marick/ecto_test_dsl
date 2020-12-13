defmodule Link.CrossReferenceTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  alias T.Parse.Types.CrossReference
  import T.Build

  @example_has_5 %{een_t(:example) => %{id: 5}}

  test "expand_in_list success cases" do
    expect = fn [list, previously], expected ->
      assert CrossReference.expand_in_list(list, previously) == expected
    end

    [ [    ], %{                      } ] |> expect.([    ])
    [ [a: 5], %{                      } ] |> expect.([a: 5])
    [ [a: 5], %{een_t(:example) => "..."} ] |> expect.([a: 5])

    [ [a: id_of(:example)], @example_has_5] |> expect.([a: 5])

    [ [:z, {:a, id_of(:example)}], @example_has_5] |> expect.([:z, {:a, 5}])
  end

  test "expand_in_list failure" do
    assertion_fails("There is no example named `:examp` in CrossReferenceTest",
      fn ->
        CrossReference.expand_in_list([a: id_of(:examp)], @example_has_5)
      end)
  end
end 
