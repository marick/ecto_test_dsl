defmodule Parse.InternalFunctions.ExampleReferencesTest do
  use TransformerTestSupport.Case
  use T.Predefines

  describe "basic parsing" do 
    test "id_of" do
      assert id_of(animal: Examples) == FieldRef.new(id: een(animal: Examples))
      assert id_of(:animal) == FieldRef.new(id: een(animal: __MODULE__))
    end
  end


  defmodule Examples do 
    use Template.Trivial
  end

  describe "id_of" do 
    test "instances of `id_of` generate a previously" do
      test_data = 
        Examples.started()
        |> workflow(:valid, ok: [params(a: 1, b: 2)])
        |> workflow(:invalid, similar: [
              params_like(:ok, except: [a: id_of(species: ExampleModule)])
           ])

      assert example(test_data, :similar).setup_instructions ==
          [insert: een(species: ExampleModule)]
    end

    test "adds on to existing setup" do
      test_data = 
        Examples.started()
        |> workflow(:invalid, name: [
             params(a: id_of(species: ExampleModule),
                    b: id_of(:thing)),
             previously(insert: een(:noog))
        ])

      assert example(test_data, :name).setup_instructions ==
          [insert: een(:noog),
           insert: een(species: ExampleModule),
           insert: een(thing: __MODULE__)]
    end
  end
  
  
end
