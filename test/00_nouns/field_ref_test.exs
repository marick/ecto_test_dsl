defmodule Nouns.FieldRefTest do
  use TransformerTestSupport.Case

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
      neighborhood = %{een(:neighbor) => %{id: 5}}

      assert FieldRef.dereference(ref, in: neighborhood) == 5
    end

    test "no such example" do 
      ref = FieldRef.new(id: een(:neighbor))
      neighborhood = %{}
      
      assertion_fails("There is no example named `:neighbor` in FieldRefTest",
        fn ->
          FieldRef.dereference(ref, in: neighborhood)
        end)
    end

    test "no such field" do 
      ref = FieldRef.new(id: een(:neighbor))
      neighborhood = %{een(:neighbor) => %{not_id: 5}}
      
      assertion_fails("There is no key named `:id`",
        fn ->
          FieldRef.dereference(ref, in: neighborhood)
        end)
    end
  end
end 
