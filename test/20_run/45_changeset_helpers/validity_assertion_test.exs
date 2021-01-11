defmodule Run.ChangesetHelpers.ValidityIsCheckedHelperTest do
  use TransformerTestSupport.Case
  alias T.Run.Steps

  test "helper function" do
    a = nonflow_assertion_runners_for(fn [workflow_name, changeset] ->
      Steps.validity_assertions(workflow_name)
      |> Steps.run_assertions(changeset, :some_example_name)
    end)

    [:validation_error, ChangesetX.invalid_changeset] |> a.pass.()
    [:validation_error, ChangesetX.valid_changeset]   |> a.fail.(
        message: ~r/:some_example_name/,
        message: ~r/The changeset is supposed to be invalid/,
        message: ~r/Changeset.* valid.: true/)

    [:success         , ChangesetX.invalid_changeset]   |> a.fail.(
        message: ~r/:some_example_name/,
        message: ~r/The changeset is invalid/,
        message: ~r/Changeset.* valid.: false/)
    [:success         , ChangesetX.valid_changeset] |> a.pass.()
  end
end
