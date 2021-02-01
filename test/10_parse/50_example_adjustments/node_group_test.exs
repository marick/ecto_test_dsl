defmodule Parse.Node.NodeGroupTest do
  use EctoTestDSL.Case
  import FlowAssertions.Define.Defchain
  alias T.Parse.Node
  import T.Parse.InternalFunctions


  describe "handle_eens" do
    defchain assert_eenified(example, kws) do
      for {field, expected_eens} <- kws do 
        Map.get(example, field)
        |> Node.EENable.eens
        # This shows field has had ensure_eens called on it
        |> assert_equal(expected_eens)
      end
    end

    defp handle_eens(kws) do
      example = Enum.into(kws, %{})
      Node.Group.handle_eens(example, SomeModule)
    end

    setup do
      data = %{
        previously_a: Node.Previously.parse(insert: :a),  # produces...
        een_a: een(a: SomeModule),
        
        refers_to_b: Node.Params.parse(a: 1, b_id: id_of(:other_example)),
        een_b: een(other_example: __MODULE__),
      }
      [data: data]
    end
    
    test "creates a master list of eens and updates example fields", %{data: d} do
      handle_eens(       setup_instructions:  d.previously_a, params:  d.refers_to_b)

      |> assert_eenified(setup_instructions: [d.een_a],       params: [d.een_b]     )
      |> assert_field(eens: in_any_order(    [d.een_a,                 d.een_b]    ))
    end

    test "missing fields are not a problem", %{data: d} do
      handle_eens(       setup_instructions:  d.previously_a)   # no params data
 
      |> assert_eenified(setup_instructions: [d.een_a])
      |> assert_field(                 eens: [d.een_a])
    end
    
    test "only eenable fields are processed", %{data: d} do
      handle_eens(       setup_instructions:  d.previously_a, other_key: "and_value")
      |> assert_eenified(setup_instructions: [d.een_a])
      |> assert_field(                 eens: [d.een_a])
    end
  end
end
