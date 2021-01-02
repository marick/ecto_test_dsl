defmodule SmartGet.ChangesetChecks.ValidInvalidTest do
  use TransformerTestSupport.Case
  alias T.SmartGet.ChangesetChecks, as: Checks
  use T.Parse.All
  alias T.Run.RunningExample
  alias Template.Dynamic

  defmodule Examples, do: use Template.EctoClassic.Insert
  
  # ----------------------------------------------------------------------------
  describe "dependencies on workflow" do
    test "what becomes valid and what becomes invalid" do
      expect = fn workflow_name, expected ->
        Dynamic.example_in_workflow(Examples, workflow_name)
        |> Checks.get_validation_checks(previously: %{})
        |> assert_equal([expected])
      end

      :validation_error   |> expect.(:invalid)
      :validation_success |> expect.(  :valid)
      :constraint_error   |> expect.(  :valid)
    end

    test "checks are added to the beginning" do
      Dynamic.example_in_workflow(Examples, :validation_success,
        [changeset(no_changes: [:date])])
      |> Checks.get_validation_checks(previously: %{})
      |> assert_equal([:valid, {:no_changes, [:date]}])
    end
  end
end
