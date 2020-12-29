defmodule Build.KeyValidationTest do
  use TransformerTestSupport.Case
  alias T.Build.KeyValidation
  alias T.Messages
  

  test "validation" do
    reorganized = fn required, optional, map ->
      # reorganized for better narrative flow in test table
      assert KeyValidation.assert_valid_keys(map, required, optional) == map
      required  # kludge for `pass`
    end
    
    a = assertion_runners_for(reorganized)

    # missing keys
    [[:required], [], %{required: 1}] |> a.pass.()
    [[:required], [], %{           }] |> a.fail.(Messages.invalid_keys())
                                      |> a.plus.(left: [missing: [:required],
                                                        extras: []])
    # extra keys
    [[], [:allowed], %{allowed: 1}] |> a.pass.()
    [[], [:allowed], %{typoe:   1}] |> a.fail.(Messages.invalid_keys())
                                    |> a.plus.(left: [missing: [], 
                                                     extras: [:typoe]])

    # Both missing and extra
    [ [:required1,   :required2],
                                  [:allowed1, :not_used],
      %{required1: 1, required2: 2, allowed1: 3}] |> a.pass.()


    # Both
    [ [:required1,   :turns_out_to_be_missing],
                                  [:allowed1, :not_used],
      %{required1: 1,              allowed1: 3,           typoe: 4}]
    |> a.fail.(Messages.invalid_keys())
    |> a.plus.(left: [missing: [:turns_out_to_be_missing], extras: [:typoe]])   
  end
    
end  
