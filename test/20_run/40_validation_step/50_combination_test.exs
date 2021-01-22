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
      module_under_test: Schema,
      neighborhood: %{})
    stub_history(params: %{})
    :ok
  end

#  defp run(), do: Steps.check_validation_changeset(:running, :changeset_from_params)
#  defp pass(), do: assert run() == :uninteresting_result

  IO.inspect "This is now a sequencing test for EctoClassic.Insert"
  
  @tag :skip
  test "validity assertion comes first" do
    # wrong_value = [changes: %{age: 6, age_plus: "WRONG"}]
    # stub(field_calculators: [age_plus: on_success(&(&1+1), applied_to: [:age])])


    # # Valid changeset
    # expect_field_failure = ChangesetX.valid_changeset(wrong_value)
    #                                  #^^^^^
    # stub_history(changeset_from_params: expect_field_failure)
    
    # assertion_fails(~r/Example `:example`: Field `:age_plus` has the wrong value/, 
    #   fn ->
    #     run()
    #   end)

    # # Invalid changeset
    # expect_validity_failure = ChangesetX.invalid_changeset(wrong_value)
    #                                     #^^^^^^^
    # stub_history(changeset_from_params: expect_validity_failure)

    # assertion_fails(~r/expects a valid changeset/, 
    #   fn ->
    #     run()
    #   end)
  end

  @tag :skip
  test "no check added when a validation failure is expected" do
  #   stub(field_calculators: [age_plus: on_success(Date.from_iso8601!(:age))])
  #   stub(workflow_name: :validation_error)
    
  #   changeset = ChangesetX.invalid_changeset(changes: %{age: "wrong"})
  #   stub_history(changeset_from_params: changeset)

  #   actual = Steps.field_calculation_checks(:running, :changeset_from_params)
  #   assert actual == :uninteresting_result
  end


end
