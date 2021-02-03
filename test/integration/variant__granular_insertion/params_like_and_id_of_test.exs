defmodule Integration.ParamLikeAndIdOfTest do
  use EctoTestDSL.Case
  alias Integration.{Animal,Species}
  use Integration.Support

  defmodule Examples do
    use EctoTestDSL.Variants.PhoenixGranular.Insert
    use Integration.Support
    
    def create_test_data() do
      start(
        module_under_test: Animal.Schema,
        repo: Unused,
        insert_with: &tunable_insert/2,
        format: :raw
      ) |>

      workflow(:validation_success,
        animal:  [
          params(name: "bossie", species_id: id_of(bovine: Species.Examples))
        ],
        animal_like_1: [
          params_like(:animal, except: [exception: 1])
        ],
        animal_like_2: [
          params_like(:animal_like_1, except: [exception: 222])
        ]
      )
    end
  end

  @species_id 3333

  setup do 
    insert_returns {:ok, %{id: @species_id}}, in: Species.Examples
    :ok
  end

  test "`id_of` and `params`" do
    Examples.Tester.params(:animal)
    |> assert_fields(name: "bossie",
                     species_id: @species_id)
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
end  
