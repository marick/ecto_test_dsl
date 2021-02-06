defmodule EctoTestDSL.Run.Steps.Ecto do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  use EctoTestDSL.Drink.AndRun

  import T.Run.Steps.Util

  # ----------------------------------------------------------------------------

  def try_changeset_insertion(running, which_changeset) do
    from(running, use: [:repo])
    from_history(running, changeset: which_changeset)    

    apply(RunningExample.insert_with(running), [repo, changeset])
  end

  def ok_content(running, which_step) do
    extract_content(running, :ok_content, which_step)
  end

  def error_content(running, which_step) do
    extract_content(running, :error_content, which_step)
  end

  defp extract_content(running, extractor, which_step) do
    from(running, use: [:name])
    from_history(running, value: which_step)

    adjust_assertion_message(
      fn ->
        apply(FlowAssertions.MiscA, extractor, [value])
      end,
      identify_example(name))
  end

  def field_checks(running, which_step) do
    from(running, use: [:neighborhood, :name, :field_checks])
    from_history(running, selected: which_step)

    expected =
      Neighborhood.Expand.keyword_values(field_checks, with: neighborhood)

    adjust_assertion_message(
      fn ->
        apply FlowAssertions.MapA, :assert_fields, [selected, expected]
      end,
      identify_example(name))

    :uninteresting_result
  end

  def params_from_selecting(running) do
    from(running, use: [:neighborhood, :params_from_selecting])
    Map.get(neighborhood, params_from_selecting)
  end
end
