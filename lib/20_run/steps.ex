defmodule TransformerTestSupport.Run.Steps do
  use TransformerTestSupport.Drink.Me
  use TransformerTestSupport.Drink.AssertionJuice
  use TransformerTestSupport.Drink.AndRun

  use FlowAssertions.Ecto
  import Mockery.Macro
  alias T.Run.ChangesetChecks, as: CC

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
    example_name = mockable(RunningExample).name(running)
    changeset = mockable(RunningExample).step_value!(running, which_changeset)
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

  def check_validation_changeset(running, which_changeset) do
    # Used throughout
    example_name = mockable(RunningExample).name(running)
    changeset = mockable(RunningExample).step_value!(running, which_changeset)
    
    # Check changeset valid field
    workflow_name = mockable(RunningExample).workflow_name(running)

    # User checks
    neighborhood = mockable(RunningExample).neighborhood(running)
    user_checks =
      mockable(RunningExample).validation_changeset_checks(running)
      |> Neighborhood.Expand.changeset_checks(neighborhood)
    run_user_checks(user_checks, example_name, changeset)

    # as_cast checks
    params = mockable(RunningExample).step_value!(running, :params)
    excluded_fields = CC.unique_fields(user_checks)
    
    running
    |> mockable(RunningExample).as_cast
    |> AsCast.subtract(excluded_fields)
    |> AsCast.assertions(params)
    |> run_assertions(changeset, example_name)

    # field calculation checks
    if mockable(RunningExample).workflow_name(running) != :validation_error do 
      running
      |> mockable(RunningExample).field_calculators
      |> FieldCalculator.subtract(excluded_fields)
      |> FieldCalculator.assertions(changeset)
      |> run_assertions(changeset, example_name)
    end
    
    :uninteresting_result
  end

  defp run_user_checks(checks, example_name, changeset) do
    checks
    |> ChangesetAssertions.from
    |> run_assertions(changeset, example_name)
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

  def insert_changeset(running, which_changeset) do
    changeset = RunningExample.step_value!(running, which_changeset)
    repo = RunningExample.repo(running)
    apply RunningExample.insert_with(running), [repo, changeset]
  end

  def check_insertion_result(running, insertion_step) do
    name = mockable(RunningExample).name(running)
    case mockable(RunningExample).step_value!(running, insertion_step) do
      {:ok, _result} -> 
        :uninteresting_result
      wrong -> 
        elaborate_flunk(
          context(name, "unexpected insertion failure"),
          left: wrong)
    end
  end
  
  def check_constraint_changeset(running, which_changeset) do
    error_case(running,
      mockable(RunningExample).step_value!(running, which_changeset))
  end

  defp error_case(running, {:error, changeset}) do
    example_name = mockable(RunningExample).name(running)
    neighborhood = mockable(RunningExample).neighborhood(running)

    # Just user checks for constraint errors
    mockable(RunningExample).constraint_changeset_checks(running)
    |> Neighborhood.Expand.changeset_checks(neighborhood)
    |> run_user_checks(example_name, changeset)
    
    :uninteresting_result
  end

  defp error_case(running, other) do
    name = mockable(RunningExample).name(running)
    elaborate_flunk(
      context(name, "expected an error tuple containing a changeset"),
      left: other)
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
