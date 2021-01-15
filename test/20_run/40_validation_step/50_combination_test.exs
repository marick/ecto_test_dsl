defmodule Run.ValidationStep.CombinationTest do
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
      field_calculators: [], 
      module_under_test: Schema)
    stub_history(params: %{})
    :ok
  end

  defp run(), do: Steps.check_validation_changeset__2(:running, :make_changeset)
  defp pass(), do: assert run() == :uninteresting_result

  test "validity assertion comes first" do
    wrong_value = [changes: %{age: 6, age_plus: "WRONG"}]
    stub(field_calculators: [age_plus: on_success(&(&1+1), applied_to: [:age])])


    # Valid changeset
    expect_field_failure = ChangesetX.valid_changeset(wrong_value)
                                     #^^^^^
    stub_history(make_changeset: expect_field_failure)
    
    assertion_fails(~r/Example `:example`: Field `:age_plus` has the wrong value/, 
      fn ->
        run()
      end)

    # Invalid changeset
    expect_validity_failure = ChangesetX.invalid_changeset(wrong_value)
                                        #^^^^^^^
    stub_history(make_changeset: expect_validity_failure)

    assertion_fails(~r/expects a valid changeset/, 
      fn ->
        run()
      end)
  end

  test "a user assertion overrides `as_cast`" do
    stub(as_cast: AsCast.new(Schema, [:age]))
    stub_history(params: %{"age" => "5858"})   # Cast value will be ignored
    # ... in favor of:
    stub(validation_changeset_checks: [changes:  [age: 0]])

    stub_history(make_changeset: ChangesetX.valid_changeset([changes: %{age: 0}])) 
    pass()
  end

  test "a user assertion overrides field calculation" do
    stub(field_calculators: [age_plus: on_success(&(&1+1), applied_to: [:age])])

    stub(validation_changeset_checks: [changes:  [age_plus: 0]])

    stub_history(make_changeset: ChangesetX.valid_changeset([changes: %{age_plus: 0}]))
    pass()
  end


  # age_plus: on_success(&(&1+1), applied_to: [:age])],
end
