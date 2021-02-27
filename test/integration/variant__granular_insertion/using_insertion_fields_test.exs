defmodule Integration.UsingInsertionFieldsTest do
  use EctoTestDSL.Case
  alias Integration.{Animal,Species}
  use Integration.Support

  defmodule Examples do
    use EctoTestDSL.Variants.PhoenixGranular.Insert
    use Integration.Support
    
    def create_test_data() do
      start(
        module_under_test: Animal.Schema,
        repo: "there is no repo",
        insert_with: &tunable_insert/2
      ) |>

      workflow(:success,
        animal:  [
          params(name: "bossie", date_string: "2001-01-01", age: 5,
            species_id: id_of(bovine: Species.Examples)),
          fields(species_id: id_of(bovine: Species.Examples))
        ]
      )
    end
  end

  @species_id 3333

  setup do
    insert_returns {:ok, %{id: @species_id}}, in: Species.Examples
    :ok
  end

  test "fields check uses reference to species id" do
    insert_returns {:ok, %{species_id: "not 3333"}}, in: Examples

    assertion_fails(~r/Field `:species_id` has the wrong value/,
      [left: "not 3333",
       right: 3333],
      fn -> 
        Examples.Tester.check_workflow(:animal)
      end)
  end
end  
