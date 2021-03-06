defmodule Nouns.FieldRefTest do
  use EctoTestDSL.Case
  alias T.Nouns.RefHolder

  test "creation" do
    expect = fn een, kvs ->
      assert Map.from_struct(een) == Enum.into(kvs, %{})
    end

    FieldRef.new(example_name: "some een")
    |> expect.(field: :example_name, een: "some een")
  end


  describe "dereference" do 
    test "success" do
      ref = FieldRef.new(id: een(:neighbor))
      neighborhood = %{een(:neighbor) => Neighborhood.Value.inserted(%{id: 5})}

      assert RefHolder.dereference(ref, in: neighborhood) == 5
    end

    test "no such example" do 
      ref = FieldRef.new(id: een(:neighbor))
      neighborhood = %{}
      
      assertion_fails("There is no example named `:neighbor` in FieldRefTest",
        fn ->
          RefHolder.dereference(ref, in: neighborhood)
        end)
    end

    test "no such field" do 
      ref = FieldRef.new(id: een(:neighbor))
      neighborhood = %{een(:neighbor) => Neighborhood.Value.inserted(%{not_id: 5})}
      
      assertion_fails("There is no key named `:id`",
        fn ->
          RefHolder.dereference(ref, in: neighborhood)
        end)
    end
  end
end 
