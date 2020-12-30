defmodule Parse.Adjustments.CrossExampleTest do
  use TransformerTestSupport.Case

  defmodule Examples do
    use Template.EctoClassic.Insert

    def create_test_data() do
      started() |>

      workflow(:success,
        species: [params(name: "bovine")],

        animal:  [
          params(name: "bossie", species_id: id_of(:species)),
          changeset(changed: [species_id: id_of(:species)])
        ],
        animal2: [
          params_like(:animal)
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
  defp changes_for(example_name) do
    get_for(example_name, :changeset_for_validation_step)
    |> Keyword.get(:changed)
  end

  @expected_field_ref FieldRef.new(id: een(:species, Examples))
  
  test "`id_of` and `params`" do
    params_for(:animal)
    |> assert_field(species_id: @expected_field_ref)
  end

  test "`id_of` and `params_like`" do
    changes_for(:animal)
    |> Keyword.get(:species_id)
    |> assert_equal(@expected_field_ref)

    params_for(:animal2)
    |> assert_field(name: "bossie",
                    species_id: @expected_field_ref)
  end
end  
