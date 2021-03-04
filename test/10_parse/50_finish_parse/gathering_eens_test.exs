defmodule Parse.FinishParse.GatheringEensTest do
  use EctoTestDSL.Case
  use T.Predefines
  use T.Parse.Exports


  defmodule Examples do
    use Template.PhoenixGranular.Insert

    def params_ref, do: id_of(params: Example1)
    def params_like_ref, do: id_of(params_like: Example2)
    def changeset_checks_ref, do: id_of(changeset_checks: Example3)
    def fields_ref, do: id_of(fields: Example4)
    def field_like_exception, do: id_of(fields_like: Example5)

    def create_test_data do
      Examples.started()

      workflow(:success,
        example: [
          params(params_id: params_ref()),
          changeset(changes: [x: changeset_checks_ref()]),
          fields(x: fields_ref())
        ],
        
        later: [
          params_like(:example, except: [params_like_id: params_like_ref()]),
          fields_like(:success, except: [params_like_id: field_like_exception()])
        ]
      )
    end
  end


  describe "all the example functions that use eens have those eens collected" do 
    test "direct references" do
      expected = [
        Examples.params_ref.een,
        Examples.changeset_checks_ref.een,
        Examples.fields_ref.een,
      ]
      
      Examples.Tester.example(:example).eens
      |> assert_good_enough(in_any_order(expected))
    end

    test "indirect (`like`)references" do
      expected = [
        Examples.params_ref.een,
        Examples.params_like_ref.een,
        een(success: Examples),
        Examples.field_like_exception.een
      ]
      
      Examples.Tester.example(:later).eens
      |> assert_good_enough(in_any_order(expected))
    end
  end
  
end
