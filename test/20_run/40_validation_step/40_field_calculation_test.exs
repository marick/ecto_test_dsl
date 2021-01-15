defmodule Run.ValidationStep.FieldCalculationTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs
  import T.Parse.InternalFunctions

  defmodule Schema do
    use Ecto.Schema
    alias Ecto.Changeset
    schema "bogus" do 
      field :age, :integer
      field :age_plus, :integer
    end
    
    def changeset(struct, params) do
      cast_value = struct |> Changeset.cast(params, [:age])
      Changeset.put_change(cast_value, :age_plus, cast_value.changes.age + 1)
    end
  end


  setup do
    stub(workflow_name: :success, name: :example,
      validation_changeset_checks: [],
      as_cast: AsCast.nothing,
      module_under_test: Schema)
    stub_history(params: %{})
    :ok
  end

  defp run([changes: changes]) do
    changeset = ChangesetX.valid_changeset(changes: changes)
    stub_history(make_changeset: changeset)
    Steps.check_validation_changeset(:running, :make_changeset)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  test "changeset has correct calculation" do
    stub(field_calculators: [age_plus: on_success(&(&1+1), applied_to: [:age])])

    passes = [changes: %{age: 6, age_plus: 7 }]
    fails =  [changes: %{age: 6, age_plus: 77}]

    pass(passes)

    assertion_fails(~r/Example `:example`: Field `:age_plus` has the wrong value/, 
      [message: ~r/Changeset:.*age_plus: 77/,
       expr: "on_success(<fn>, applied_to: [:age])",
       left: 77,
       right: 7],
      fn ->
        run(fails)
      end)
  end
    
end
