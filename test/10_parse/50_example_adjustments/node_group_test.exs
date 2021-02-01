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

    defp handle_eens(kws) do
      example = Enum.into(kws, %{})
      Node.Group.handle_eens(example, SomeModule)
    end

    setup do
      [een_a: een(a: SomeModule),
       een_b: een(other_example: __MODULE__)
      ]
    end
    
    test "creates a master list of eens and updates example fields",
      %{een_a: een_a, een_b: een_b} do

      handle_eens(setup_instructions: Node.Previously.parse(insert: :a),
                  params: Node.Params.parse(a: 1, b_id: id_of(:other_example)))
      |> assert_field_has_been_eenified(:setup_instructions, [een_a])
      |> assert_field_has_been_eenified(:params,             [een_b])
      |> assert_field(eens: in_any_order([een_a, een_b]))
    end

    test "missing fields are not a problem", %{een_a: een_a} do
      handle_eens(setup_instructions: Node.Previously.parse(insert: :a))
      |> assert_field_has_been_eenified(:setup_instructions, [een_a])
      |> assert_field(eens: [een_a])
    end
    
    test "only eenable fields are processed", %{een_a: een_a} do
      handle_eens(setup_instructions: Node.Previously.parse(insert: :a),
                  some_random_key: "some irrelevant value")
      |> assert_field_has_been_eenified(:setup_instructions, [een_a])
      |> assert_field(eens: [een_a])
    end
  end
end
