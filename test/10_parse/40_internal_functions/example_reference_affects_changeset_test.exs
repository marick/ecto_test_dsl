defmodule Parse.InternalFunctions.ExampleReferenceAffectsChangesetTest do
  use EctoTestDSL.Case

  defmodule Examples do
    use Template.PhoenixGranular.Insert

    def create_test_data() do
      started() |>

      workflow(:success,
        species: [params(name: "bovine")],

        animal:  [
          params(name: "bossie", species_id: id_of(:species)),
          changeset(changed: [species_id: id_of(:species)])
        ]
      )
    end
  end

  defp get_for(example_name, key) do 
    Examples.create_test_data.examples
    |> Keyword.get(example_name)
    |> Map.get(key)
  end
  
  defp changes_for(example_name) do
    get_for(example_name, :validation_changeset_checks)
    |> Keyword.get(:changed)
  end

  @expected_field_ref FieldRef.new(id: een(:species, Examples))
  
  test "`id_of` and `params_like`" do
    changes_for(:animal)
    |> Keyword.get(:species_id)
    |> assert_equal(@expected_field_ref)
  end
end  
