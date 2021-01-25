defmodule Parse.InternalFunctions.ExampleReferenceAffectsSetupTest do
  use EctoTestDSL.Case
  use T.Predefines

  defmodule Examples do 
    use Template.Trivial
  end

  describe "id_of" do 
    test "instances of `id_of` generate a setup" do
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
             previously(insert: :noog)
        ])

      assert example(test_data, :name).setup_instructions ==
          [insert: een(:noog, :default_trivial_examples_module),
           insert: een(species: ExampleModule),
           insert: een(thing: __MODULE__)]
    end
  end
end
