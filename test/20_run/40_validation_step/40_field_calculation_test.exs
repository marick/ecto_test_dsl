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
  test "a special error when a supposed-to-be-changed field is not present" do
    stub(field_calculators: [age_plus: on_success(&(&1+1), applied_to: [:age])])

    input = [changes: %{age: 3}]

        run(input)
    

    assertion_fails(~r/Example `:example`: Field `:age_plus` is missing/, 
      [message: ~r/The changeset has all the prerequisites to calculate `:age_plus`/,
       expr: "on_success(<fn>, applied_to: [:age])",
       left: %{age: 3},
       right: ["calculated value": [age_plus: 4]]],
      fn ->
        run(input)
      end)
  end

  test "the calculation blows up with a message" do
    stub(field_calculators: [age_plus: on_success(Date.from_iso8601!(:age))])

    input = [changes: %{age: "2001-01-3", age_plus: 7 }]

    assertion_fails(~r/Example `:example`: Exception raised while calculating value for `:age_plus`/, 
      [message: ~r/cannot parse "2001-01-3" as date, reason: :invalid_format/,
       expr: "on_success(Date.from_iso8601!(:age))",
       left: ["Here are the actual arguments used": ["2001-01-3"]]],
      fn ->
        run(input)
      end)
  end

  test "the calculation blows up with no message" do
    stub(field_calculators: [age_plus: on_success(Date.from_iso8601!(:age))])

    input = [changes: %{age: 6, age_plus: 7 }]

    assertion_fails(~r/Example `:example`: Exception raised while calculating value for `:age_plus`/, 
      [message: ~r/%FunctionClauseError/,
       expr: "on_success(Date.from_iso8601!(:age))",
       left: ["Here are the actual arguments used": [6]]],
      fn ->
        run(input)
      end)
  end

  test "no check added when a validation failure is expected" do
    stub(field_calculators: [age_plus: on_success(Date.from_iso8601!(:age))])
    stub(workflow_name: :validation_error)
    
    changeset = ChangesetX.invalid_changeset(changes: %{age: "wrong"})
    stub_history(make_changeset: changeset)

    actual = Steps.check_validation_changeset(:running, :make_changeset)
    assert actual == :uninteresting_result
  end
end
