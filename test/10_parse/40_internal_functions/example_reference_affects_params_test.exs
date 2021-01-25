defmodule Parse.InternalFunctions.ExampleReferenceAffectsParamsTest do
  use EctoTestDSL.Case

  defmodule Examples do
    use Template.PhoenixGranular.Insert

    def create_test_data() do
      started() |>

      workflow(:success,
        species: [params(name: "bovine")],

        animal:  [
          params(name: "bossie", species_id: id_of(:species))
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

  defp get_for(example_name, key) do 
    Examples.create_test_data.examples
    |> Keyword.get(example_name)
    |> Map.get(key)
  end
  
  defp params_for(example_name), do: get_for(example_name, :params)

  @expected_field_ref FieldRef.new(id: een(:species, Examples))
  
  test "`id_of` and `params`" do
    params_for(:animal)
    |> assert_field(species_id: @expected_field_ref)
  end

  test "`id_of` and `params_like`" do
    params_for(:animal_like_1)
    |> assert_field(name: "bossie",
                    species_id: @expected_field_ref,
                    exception: 1)

    params_for(:animal_like_2)
    |> assert_field(name: "bossie",
                    species_id: @expected_field_ref,
                    exception: 222)

  end
end  
