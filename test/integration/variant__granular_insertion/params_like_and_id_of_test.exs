defmodule Integration.ParamLikeAndIdOfTest do
  use EctoTestDSL.Case
  alias Integration.{Animal,Species}
  use Integration.Support   #<<<<<<<<<<<<<< Macro magic in here

  defmodule Examples do
    use EctoTestDSL.Variants.PhoenixGranular.Insert
    use Integration.Support
    
    def create_test_data() do
      start(
        module_under_test: Animal.Schema,
        repo: Unused,
        insert_with: &tunable_insert/2,  #<<< this generated function
                                         #<<< provides a "cut point" for stubbing
        format: :raw
      ) |>

      workflow(:validation_success,
        animal:  [
          ## Below, we generate form params from the primary key in a "species" row.
          ## Which means we have to do an `Ecto.insert` before we can
          ## create parameters to use in a test. 
          params(name: "bossie", species_id: id_of(bovine: Species.Examples))
        ],
        animal_like_1: [
          params_like(:animal, except: [exception: 1])
        ],
        animal_like_2: [
          params_like(:animal_like_1, except: [exception: 222])
        ],

        multi_params: [
          params(name: "bossie"),
          params(species_id: id_of(bovine: Species.Examples))
        ]
      )
    end
  end

  @species_id 3333

  setup do
    ## In general, we don't want to use the real `Ecto.insert` because we want
    ## easy control over, for example, constraint errors.
    ## In this case, we stub out `Ecto.insert` for a species value to
    ## produce a value to be checked in testing.
    insert_returns {:ok, %{id: @species_id}}, in: Species.Examples
    :ok
  end

  test "`id_of` and `params`" do
    Examples.Tester.params(:animal)
    |> assert_fields(name: "bossie",
                     species_id: @species_id)  ##<<<< Like this!
  end

  test "`id_of` and `params_like`" do
    Examples.Tester.params(:animal_like_1)
    |> assert_field(name: "bossie",
                    species_id: @species_id,
                    exception: 1)

    Examples.Tester.params(:animal_like_2)
    |> assert_field(name: "bossie",
                    species_id: @species_id,
                    exception: 222)
  end

  test "multiple params" do
    Examples.Tester.params(:multi_params)
    |> assert_fields(name: "bossie",
                     species_id: @species_id)
  end
end  
