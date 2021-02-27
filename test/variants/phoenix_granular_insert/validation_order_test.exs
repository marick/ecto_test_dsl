defmodule Variants.PhoenixGranular.ValidationOrderTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.Parse.InternalFunctions

  defmodule Schema do
    use Ecto.Schema
    alias Ecto.Changeset
    schema "bogus" do 
      field :age, :integer
      field :age_plus, :integer
    end
    
    def changeset(struct, params) do
      struct
      |> Changeset.cast(params, [:age])
      |> age_plus
    end

    def age_plus(changeset) do
      case changeset.valid? do
        true ->
          Changeset.put_change(changeset, :age_plus, changeset.changes.age + 1)
        false ->
          changeset
      end
    end
  end
  

  defmodule Examples do
    use EctoTestDSL.Variants.PhoenixGranular.Insert
    
    def create_test_data do 
      start(
        module_under_test: Schema,
        repo: "there is no repo"
      ) |>

      field_transformations(as_cast: [:age],
        age_plus: on_success(&(&1+1), applied_to: [:age])
      ) |>
    
      workflow(                       :success,
        validity_assertion_comes_first: [
          params(age: "1b"),
          changeset(changes: [age: 1])
        ]) |> 


      workflow(                       :validation_error,
        invalidity_assertion_comes_first: [
          params(age: "1"),
          changeset(changes: [age: 100000])
        ])
      
    end
  end

  test "validity assertion comes first" do
    assertion_fails(~r/workflow `:success` expects a valid changeset/,
      fn -> 
        Examples.Tester.check_workflow(:validity_assertion_comes_first)
      end)
  end

  test "also INvalidation check" do
    assertion_fails(~r/workflow `:validation_error` expects an invalid changeset/,
      fn -> 
        Examples.Tester.check_workflow(:invalidity_assertion_comes_first)
      end)
  end

end
