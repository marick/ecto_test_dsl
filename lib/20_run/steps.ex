defmodule EctoTestDSL.Run.Steps do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AssertionJuice
  use EctoTestDSL.Drink.AndRun

  use FlowAssertions.Ecto
  import Mockery.Macro
  alias T.Run.ChangesetChecks, as: CC
  alias T.Neighborhood.Expand

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

  # ----------------------------------------------------------------------------
  
  defp context(name, message),
    do: "Example `#{inspect name}`: #{message}"

  defp error_message(name, message, changeset) do
    """
    #{context(name, message)}
    Changeset: #{inspect changeset}
    """
  end
end
