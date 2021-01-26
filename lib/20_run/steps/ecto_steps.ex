defmodule EctoTestDSL.Run.Steps.Ecto do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  use EctoTestDSL.Drink.AndRun

  use FlowAssertions.Ecto
  import Mockery.Macro
  alias T.Run.ChangesetChecks, as: CC
  alias T.Neighborhood.Expand
  import T.Run.Steps.Util

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
