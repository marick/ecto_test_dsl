defmodule Run.Steps.ValidityTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs

  setup do
    stub(workflow_name: :workflow, name: :example)
    :ok
  end

  defp run([changeset, step_name]) do
    stub_history(changeset_from_params: changeset)
    apply Steps, step_name, [:running, :changeset_from_params]
  end

  defp pass(args), do: assert run(args) == :uninteresting_result

  test "assert_valid_changeset" do 
    [ChangesetX.valid_changeset, :assert_valid_changeset] |> pass()

    assertion_fails(~r/Example `:example`/,
      [message: ~r/workflow `:workflow` expects a valid changeset/,
       expr: [changeset: [:valid, "..."]],
       left: ChangesetX.invalid_changeset],
      fn ->
        run([ChangesetX.invalid_changeset, :assert_valid_changeset])
      end)
  end

  test "refute_valid_changeset" do 
    [ChangesetX.invalid_changeset, :refute_valid_changeset] |> pass()

    assertion_fails(~r/Example `:example`/,
      [message: ~r/workflow `:workflow` expects an invalid changeset/,
       expr: [changeset: [:invalid, "..."]],
       left: ChangesetX.valid_changeset],
      fn ->
        run([ChangesetX.valid_changeset, :refute_valid_changeset])
      end)
  end

  
end
