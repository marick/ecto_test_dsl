defmodule Nouns.FieldRefTest do
  use TransformerTestSupport.Case

  test "creation" do
    expect = fn een, kvs ->
      assert Map.from_struct(een) == Enum.into(kvs, %{})
    end

    FieldRef.new(example_name: "some een")
    |> expect.(field: :example_name, een: "some een")
  end
  
end 
