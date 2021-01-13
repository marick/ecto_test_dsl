defmodule Run.ValidationStep.ChangesetValidityTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery

  setup do
    given RunningExample.name(:running), return: :example
    :ok
  end

  defp stub_changeset(changeset) do
    given RunningExample.step_value!(:running, :make_changeset), return: changeset
  end

  defp stub_workflow_name(name) do
    given RunningExample.workflow_name(:running), return: name
  end

  defp run([changeset, {:workflow, workflow_name}]) do 
    stub_changeset(changeset)
    stub_workflow_name(workflow_name)
    Steps.check_validation_changeset__2(:running, :make_changeset)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  test "expecting valid changeset; got it",
    do: [ChangesetX.valid_changeset,   workflow: :success] |> pass()
  test "expecting invalid changeset; got it",
    do: [ChangesetX.invalid_changeset, workflow: :validation_error] |> pass()

  test "expecting valid changeset; got invalid" do
    setup = [ChangesetX.invalid_changeset, workflow: :validation_success]
    assertion_fails(~r/Example `:example`/,
      [message: ~r/workflow `:validation_success` expects a valid changeset/,
       expr: [changeset: [:valid, "..."]],
       left: ChangesetX.invalid_changeset],
      fn ->
        run(setup)
      end)
  end

  test "expecting invalid changeset; got valid" do
    setup = [ChangesetX.valid_changeset, workflow: :validation_error]
    assertion_fails(~r/Example `:example`/,
      [message: ~r/workflow `:validation_error` expects an invalid changeset/,
       expr: [changeset: [:invalid, "..."]],
       left: ChangesetX.valid_changeset],
      fn ->
        run(setup)
      end)
  end
end
