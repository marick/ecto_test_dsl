defmodule EctoTestDSL.Run.Steps do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  use EctoTestDSL.Drink.AndRun

  use FlowAssertions.Ecto
  import Mockery.Macro
  alias T.Run.ChangesetChecks, as: CC
  alias T.Neighborhood.Expand
  import T.Run.Steps.Util

  # ----------------------------------------------------------------------------

  # I can't offhand think of any case where one `previously` might need to
  # use the results of another that isn't part of the same dependency tree.
  # That might change if I add a workflowy-wide or test-data-wide setup.

  # If that is done, the history must be passed in by `Run.example`

  def start_sandbox(example) do
    alias Ecto.Adapters.SQL.Sandbox

    repo = Example.repo(example)
    if repo do  # Convenient for testing, where we might be faking the repo functions.
      Sandbox.checkout(repo) # it's OK if it's already checked out.
    end
  end

  def previously(running) do
    neighborhood = RunningExample.neighborhood(running)
    instructions = RunningExample.setup_instructions(running)

    Neighborhood.Create.from_a_list(instructions, running.example, neighborhood)
  end

  # ----------------------------------------------------------------------------
  def params(running) do
    neighborhood = RunningExample.neighborhood(running)

    original_params = RunningExample.original_params(running)
    params = 
      RunningExample.format_params(running,
        Neighborhood.Expand.params(original_params, with: neighborhood))

    Trace.say(params, :params)
    params
  end

  # ----------------------------------------------------------------------------

  def changeset_from_params(running), 
    do: RunningExample.changeset_from_params(running)

  # ----------------------------------------------------------------------------

  def try_changeset_insertion(running, which_changeset) do
    changeset = RunningExample.step_value!(running, which_changeset)
    repo = RunningExample.repo(running)
    apply(RunningExample.insert_with(running), [repo, changeset])
  end

  def ok_content(running, which_step) do
    extract_content(running, :ok_content, which_step)
  end

  def error_content(running, which_step) do
    extract_content(running, :error_content, which_step)
  end

  defp extract_content(running, extractor, which_step) do
    example_name = mockable(RunningExample).name(running)
    value = mockable(RunningExample).step_value!(running, which_step)
    adjust_assertion_message(
      fn ->
        apply(FlowAssertions.MiscA, extractor, [value])
      end,
      fn message ->
        context(example_name, message)
      end)
  end

  def field_checks(running, which_step) do
    neighborhood = mockable(RunningExample).neighborhood(running)
    example_name = mockable(RunningExample).name(running)
    expected =
      mockable(RunningExample).field_checks(running)
      |> Expand.field_checks(with: neighborhood)
    value = mockable(RunningExample).step_value!(running, which_step)

    adjust_assertion_message(
      fn ->
        apply FlowAssertions.MapA, :assert_fields, [value, expected]
      end,
      fn message ->
        context(example_name, message)
      end)
    :uninteresting_result
  end

end
