defmodule Nouns.EENTest do
  use TransformerTestSupport.Case

  test "there are three special ways to create an EEN" do
    expect = fn een, kvs ->
      assert Map.from_struct(een) == Enum.into(kvs, %{})
    end

    een( example_name: Module) |> expect.(name: :example_name, module:   Module)
    een(:example_name, Module) |> expect.(name: :example_name, module:   Module)
    een(:example_name)         |> expect.(name: :example_name, module: __MODULE__)

    # And the base version
    EEN.new(:example_name, Module) |> expect.(name: :example_name, module: Module)
  end
  
end 
