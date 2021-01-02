defmodule Parse.InternalFunctions.ExampleReferenceTest do
  use TransformerTestSupport.Case
  use T.Predefines

  describe "basic parsing" do 
    test "id_of" do
      assert id_of(animal: Examples) == FieldRef.new(id: een(animal: Examples))
      assert id_of(:animal) == FieldRef.new(id: een(animal: __MODULE__))
    end
  end
end

