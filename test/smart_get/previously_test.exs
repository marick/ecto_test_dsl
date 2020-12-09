defmodule SmartGet.PreviouslyTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.SmartGet.Previously
  import T.Types, only: [een: 1]
  import T.Build

  test "expand_in_list success cases" do
    expect = fn [list, previously], expected ->
      assert Previously.expand_in_list(list, previously) == expected
    end

    [ [    ], %{                      } ] |> expect.([    ])
    [ [a: 5], %{                      } ] |> expect.([a: 5])
    [ [a: 5], %{een(:example) => "..."} ] |> expect.([a: 5])

    [ [a: id_of(:example)], %{een(:example) => %{id: 5}}] |> expect.([a: 5])
  end

  @tag :skip
  test "expand_in_list failure" do
  end

  
end 
