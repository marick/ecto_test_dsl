defmodule Parse.InternalFunctions.IdOfTest do
  use EctoTestDSL.Case
  use T.Predefines
  alias T.Parse.FinishParse
  alias T.Parse.BuildState

  test "basic parsing" do 
    assert id_of(animal: Examples) == FieldRef.new(id: een(animal: Examples))
    assert id_of(:animal) == FieldRef.new(id: een(animal: __MODULE__))
  end

  defmodule Examples do 
    use Template.PhoenixGranular.Insert
  end

  test "instances of `id_of` generate eens" do
    Examples.started()
    workflow(:success, ok: [params(a: 1, b: 2)])
    workflow(:validation_error, similar: [
          params_like(:ok, except: [a: id_of(species: ExampleModule)])
        ])
    
    test_data = 
      BuildState.current
      |> FinishParse.finish
    
    assert example(test_data, :similar).eens == [een(species: ExampleModule)]
  end
  
  test "adds on to existing eens" do
    Examples.started(examples_module: ExampleModule)
    workflow(:validation_error, name: [
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

