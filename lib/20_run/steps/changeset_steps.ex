defmodule EctoTestDSL.Run.Steps.Changeset do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  use EctoTestDSL.Drink.AndRun

  alias T.Run.ChangesetChecks, as: CC
  import T.Run.Steps.Util

  def assert_valid_changeset(running, which_changeset) do 
    validity_assertions(running, which_changeset,
      ChangesetAssertions.from(:valid), "a valid")
  end
    
  def refute_valid_changeset(running, which_changeset) do 
    validity_assertions(running, which_changeset,
      ChangesetAssertions.from(:invalid), "an invalid")
  end
    
  defp validity_assertions(running, which_changeset, assertion, error_snippet) do
    {example_name, changeset} = frequent_values(running, which_changeset)
    workflow_name = mockable(RunningExample).workflow_name(running)

    message =
      "Example `#{inspect example_name}`: workflow `#{inspect workflow_name}` expects #{error_snippet} changeset"
    adjust_assertion_message(
      fn ->
        assertion.(changeset)
      end,
      fn _ -> message end)

    :uninteresting_result
  end

  def example_specific_changeset_checks(running, which_changeset) do
    {example_name, changeset} = frequent_values(running, which_changeset)
    
    user_checks(running)
    |> ChangesetAssertions.from
    |> run_assertions(changeset, example_name)

    :uninteresting_result
  end


  def as_cast_checks(running, which_changeset) do
    {example_name, changeset} = frequent_values(running, which_changeset)

    params = mockable(RunningExample).step_value!(running, :params)
    
    running
    |> mockable(RunningExample).as_cast
    |> AsCast.subtract(excluded_fields(running))
    |> AsCast.assertions(params)
    |> run_assertions(changeset, example_name)

    :uninteresting_result
  end

  def field_calculation_checks(running, which_changeset) do
    {example_name, changeset} = frequent_values(running, which_changeset)
    
    running
    |> mockable(RunningExample).field_calculators
    |> FieldCalculator.subtract(excluded_fields(running))
    |> FieldCalculator.assertions(changeset)
    |> run_assertions(changeset, example_name)
    
    :uninteresting_result
  end

  defp frequent_values(running, which_changeset) do
    example_name = mockable(RunningExample).name(running)
    changeset = mockable(RunningExample).step_value!(running, which_changeset)
    {example_name, changeset}
  end

  defp user_checks(running) do 
    neighborhood = mockable(RunningExample).neighborhood(running)

    mockable(RunningExample).validation_changeset_checks(running)
    |> Neighborhood.Expand.changeset_checks(neighborhood)
  end

  defp excluded_fields(running) do
    user_checks = user_checks(running)
    # as_cast checks
    CC.unique_fields(user_checks)
  end    

  defp run_assertions(assertions, changeset, name) do
    adjust_assertion_message(
      fn ->
        for a <- assertions, do: a.(changeset)
      end,
      fn message ->
        error_message(name, message, changeset)
      end)
  end

  # ----------------------------------------------------------------------------
  
  def error_message(name, message, changeset) do
    """
    #{context(name, message)}
    Changeset: #{inspect changeset}
    """
  end
  
end
