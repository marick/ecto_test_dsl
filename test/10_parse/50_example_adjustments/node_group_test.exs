defmodule Parse.Node.NodeGroupTest do
  use EctoTestDSL.Case
  import FlowAssertions.Define.Defchain
  alias T.Parse.Node
  import T.Parse.InternalFunctions


  describe "handle_eens" do
    defchain assert_field_has_been_eenified(example, field, expected_eens) do 
      Map.get(example, field)
      |> Node.EENable.eens
      # This shows field has had ensure_eens called on it
      |> assert_equal(expected_eens)  
    end
    
    test "creates N" do
      example = 
        %{setup_instructions: Node.Previously.parse(insert: :a),
          params: Node.Params.parse(a: 1, b_id: id_of(:other_example))}
      
      een_a = een(a: SomeModule)
      een_b = een(other_example: __MODULE__)
      
      Node.Group.handle_eens(example, SomeModule)
      |> assert_field_has_been_eenified(:setup_instructions, [een_a])
      |> assert_field_has_been_eenified(:params,             [een_b])
      |> assert_field(eens: [een_a, een_b])
    end
  end
end
