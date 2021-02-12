defmodule EctoTestDSL.Run.Steps.Ecto do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  use EctoTestDSL.Drink.AndRun
  alias FlowAssertions.MapA

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
    from(running, use: [:neighborhood, :name, :field_checks, :fields_like])
    from_history(running, to_be_checked: which_step)

    adjust_assertion_message(fn -> 
      do_field_checks(field_checks, to_be_checked, neighborhood)
      do_fields_like(fields_like, to_be_checked, neighborhood)
    end,
      identify_example(name))

    :uninteresting_result
  end

  defp do_field_checks(field_checks, to_be_checked, neighborhood) do
    unless Enum.empty?(field_checks) do 
      expected =
        Neighborhood.Expand.keyword_values(field_checks, with: neighborhood)
      assert_fields(to_be_checked, expected)
    end
  end

  defp do_fields_like(:nothing, _, _), do: :ok
  defp do_fields_like(fields_like, to_be_checked, neighborhood) do
    reference_value = Map.get(neighborhood, fields_like.een)
    opts = expand_expected(fields_like.opts, neighborhood)

    MapA.assert_same_map(to_be_checked, reference_value, opts)
  end

  defp expand_expected(opts, neighborhood) do
    case Keyword.get(opts, :except) do
      nil ->
        opts
      kws ->
        excepts = Neighborhood.Expand.keyword_values(kws, with: neighborhood)
        Keyword.replace(opts, :except, excepts)
    end
  end

  def params_from_selecting(running) do
    from(running, use: [:neighborhood, :params_from_selecting])
    Map.get(neighborhood, params_from_selecting)
  end
end
