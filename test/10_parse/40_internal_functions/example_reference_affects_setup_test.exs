defmodule Parse.InternalFunctions.ExampleReferenceAffectsSetupTest do
  use EctoTestDSL.Case
  use T.Predefines
  alias T.Parse.FinishParse
  alias T.Parse.BuildState

  defmodule Examples do 
    use Template.Trivial
  end

  describe "id_of" do
    test "instances of `id_of` generate a setup" do
      Examples.started()
      workflow(:valid, ok: [params(a: 1, b: 2)])
      workflow(:invalid, similar: [
            params_like(:ok, except: [a: id_of(species: ExampleModule)])
          ])

      test_data = 
        BuildState.current
        |> FinishParse.finish

      assert example(test_data, :similar).eens == [een(species: ExampleModule)]
    end

    test "adds on to existing setup" do
      Examples.started(examples_module: ExampleModule)
      workflow(:invalid, name: [
            params(
              a: id_of(species: ExampleModule),
              b: id_of(:thing)),
            previously(insert: :noog)
          ])

      test_data = 
        BuildState.current
        |> FinishParse.finish

      assert_good_enough(
        example(test_data, :name).eens,
        in_any_order([een(:noog, ExampleModule),
                      een(species: ExampleModule),
                      een(thing: __MODULE__)]))
    end
  end
end
