defmodule Run.ValidationStep.ChangesetValidityTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs

  setup do
    stub(workflow_name: :success, name: :example,
      as_cast: AsCast.nothing, validation_changeset_checks: [],
      field_calculators: [])
    stub_history(params: %{})
    :ok
  end

  defp run([changeset, {:workflow, workflow_name}]) do
    stub(workflow_name: workflow_name)
    stub_history(make_changeset: changeset)
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
