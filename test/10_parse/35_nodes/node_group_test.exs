defmodule Pnode.NodeGroupTest do
  use EctoTestDSL.Case
  use T.Drink.AndParse
  use T.Parse.Exports
  import FlowAssertions.Define.Defchain

  setup do
    BuildState.put(%{examples_module: Examples})
    :ok
  end
    
  describe "creating an example from a keyword list" do
    setup do
      [expect: fn kws, expected ->
        assert Pnode.Group.squeeze_into_map(kws) == expected
      end]
    end

    test "ordinary symbols", ~M{expect} do
      [key: :value] |> expect.(%{key: :value})
      [key: :value, other: :value] |> expect.(%{key: :value, other: :value})
      
      assertion_fails("`:key` may not be repeated",
        [left: :value1, right: :value2],
        fn -> 
          Pnode.Group.squeeze_into_map(key: :value1, key: :value2)
        end)
    end

    test "merging", ~M{expect} do
      first = Pnode.Params.parse(species: "bovine")
      [key: first] |> expect.(%{key: first})

      second = Pnode.Params.parse(start_time: "now")
      expected = %{key: Pnode.Params.parse(species: "bovine", start_time: "now")}
      [key: first, key: second] |> expect.(expected)
    end

    test "two different values cannot be merged" do
      first = Pnode.ParamsLike.parse(:some_example, except: [])
      second = Pnode.Params.parse(start_time: "now")
      
      assertion_fails("You've repeated `:key`, but with incompatible values",
        [left: first, right: second],
        fn -> 
          Pnode.Group.squeeze_into_map(key: first, key: second)
        end)
    end
  end
  

  describe "handle_eens" do
    defchain assert_eenified(example, kws) do
      for {field, expected_eens} <- kws do 
        Map.get(example, field)
        |> Pnode.EENable.eens
        |> assert_equal(expected_eens)
      end
    end

    defp eens(kws) do
      example = Enum.into(kws, %{})
      Pnode.Group.collect_eens(example)
    end

    setup do
      data = %{
        previously_a: Pnode.Previously.parse(insert: :a),  # produces...
        een_a: een(a: Examples),
        
        refers_to_b: Pnode.Params.parse(a: 1, b_id: id_of(:other_example)),
        een_b: een(other_example: __MODULE__),
      }
      [data: data]
    end
    
    test "creates a master list of eens and updates example fields", %{data: d} do
      eens(                      previously:  d.previously_a, params:  d.refers_to_b)

      |> assert_eenified(        previously: [d.een_a],       params: [d.een_b]     )
      |> assert_field(eens: in_any_order(    [d.een_a,                 d.een_b]    ))
    end

    test "missing fields are not a problem", %{data: d} do
      eens(              previously:  d.previously_a)   # no params data
 
      |> assert_eenified(previously: [d.een_a])
      |> assert_field(         eens: [d.een_a])
    end
    
     test "only eenable fields are processed", %{data: d} do
      eens(              previously:  d.previously_a, other_key: "and_value")
      |> assert_eenified(previously: [d.een_a])
      |> assert_field(         eens: [d.een_a])
    end
  end

  test "exporting nodes" do
    example = %{
      params: Pnode.Params.parse(a: 1, some_id: id_of(:b)),
      irrelevant: :node,
      previously: Pnode.Previously.parse(insert: :a)
    }
      
    new_example =
      example
      |> Pnode.Group.collect_eens
      |> Pnode.Group.export

    assert_fields(new_example, 
      params: Rnode.Params.new(%{a: 1, some_id: id_of(:b)}),
      irrelevant: :node,
      eens: in_any_order([een(a: Examples), een(b: __MODULE__)]))

    refute Map.has_key?(new_example, :previously)
  end
end
