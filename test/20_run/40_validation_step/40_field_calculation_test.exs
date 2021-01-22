defmodule Run.ValidationStep.FieldCalculationTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs
  import T.Parse.InternalFunctions

  setup do
    stub(name: :example,
      validation_changeset_checks: [],
      neighborhood: %{})
    :ok
  end

  defp run([changes: changes]) do
    changeset = ChangesetX.valid_changeset(changes: changes)
    stub_history(changeset_from_params: changeset)
    Steps.field_calculation_checks(:running, :changeset_from_params)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  test "simple pass and failure" do
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

  test "transformations are only applied to changed fields" do
    stub(field_calculators: [age_plus: on_success(Date.from_iso8601!(:age))])
    pass([changes: %{}])
  end

  @tag :skip
  # Someday produce a better error messsage as shown below
  test "a supposed-to-be-calculated field is not present" do
    stub(field_calculators: [age_plus: on_success(&(&1+1), applied_to: [:age])])

    changeset_values = [changes: %{age: 3}]

        run(changeset_values)

    assertion_fails(~r/Example `:example`: Field `:age_plus` is missing/, 
      [message: ~r/The changeset has all the prerequisites to calculate `:age_plus`/,
       expr: "on_success(<fn>, applied_to: [:age])",
       left: %{age: 3},
       right: ["calculated value": [age_plus: 4]]],
      fn ->
        run(changeset_values)
      end)
  end

  test "the calculation blows up with a message" do
    stub(field_calculators: [age_plus: on_success(Date.from_iso8601!(:age))])

    changeset_values = [changes: %{age: "2001-01-3", age_plus: 7 }]

    assertion_fails(~r/Example `:example`: Exception raised while calculating value for `:age_plus`/, 
      [message: ~r/cannot parse "2001-01-3" as date, reason: :invalid_format/,
       expr: "on_success(Date.from_iso8601!(:age))",
       left: ["Here are the actual arguments used": ["2001-01-3"]]],
      fn ->
        run(changeset_values)
      end)
  end

  test "the calculation blows up with no message" do
    stub(field_calculators: [age_plus: on_success(Date.from_iso8601!(:age))])

    changeset_values = [changes: %{age: 6, age_plus: 7 }]

    assertion_fails(~r/Example `:example`: Exception raised while calculating value for `:age_plus`/, 
      [message: ~r/%FunctionClauseError/,
       expr: "on_success(Date.from_iso8601!(:age))",
       left: ["Here are the actual arguments used": [6]]],
      fn ->
        run(changeset_values)
      end)
  end

  test "a user assertion overrides field calculation" do
    stub(field_calculators: [age_plus: on_success(&(&1+1), applied_to: [:age])])
    stub(validation_changeset_checks: [changes:  [age_plus: 0]])
    
    [changes: %{age_plus: 7 }] |> pass()
  end


  test "... but does not interfere with field calculations" do
    stub(field_calculators: [age_plus: on_success(&(&1+1), applied_to: [:age])])
    stub(validation_changeset_checks: [changes: [age: 0]])

    changeset_values = [changes: %{age: 0, age_plus: 38383}]

    assertion_fails(~r/Example `:example`: Field `:age_plus` has the wrong value/,
      [expr: "on_success(<fn>, applied_to: [:age])",
       left: 38383,
       right: 1],
      fn ->
        run(changeset_values)
      end)
  end
end
