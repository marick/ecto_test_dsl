defmodule Parse.Nouns.ImpliedSetupTest do
  use EctoTestDSL.Case
  alias T.Parse.ImpliedSetup
  test "to_empty" do
    expect = fn [initial, new], expected ->
      ImpliedSetup.testable__append_to_setup(initial, new)
      |> Map.get(:setup_instructions)
      |> assert_equal(expected)
    end
    
    [%{                       } , [1, 2] ] |> expect.([1, 2])
    [%{setup_instructions: [1]} , [   2] ] |> expect.([1, 2])
    [%{setup_instructions: [ ]} , [1, 2] ] |> expect.([1, 2])

    [%{setup_instructions: [1]} , [    ] ] |> expect.([1   ])
    [%{setup_instructions: [ ]} , [    ] ] |> expect.([    ])
  end 
end 
