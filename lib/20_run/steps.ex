defmodule TransformerTestSupport.Run.Steps do
  use TransformerTestSupport.Drink.Me
  use TransformerTestSupport.Drink.AssertionJuice
  use TransformerTestSupport.Drink.AndRun

  alias T.SmartGet.{Example,ChangesetChecks}
  use FlowAssertions.Ecto
  alias FlowAssertions.Ecto.ChangesetA
  alias T.Run.Assertions
  import Mockery.Macro
  alias T.Run.ChangesetChecks, as: CC

  # Default functions

  def changeset_with__default_insert(module_under_test, params) do
    default_struct = struct(module_under_test)
    module_under_test.changeset(default_struct, params)
  end

  def insert_with__default(repo, changeset),
    do: repo.insert(changeset)
  

  # ----------------------------------------------------------------------------

  # I can't offhand think of any case where one `previously` might need to
  # use the results of another that isn't part of the same dependency tree.
  # That might change if I add a workflowy-wide or test-data-wide setup.

  # If that is done, the history must be passed in by `Run.example`

  def start_sandbox(example) do
    alias Ecto.Adapters.SQL.Sandbox

    repo = RunningExample.repo(example)
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
  
  def accept_params(running), 
    do: RunningExample.accept_params(running)

  # ----------------------------------------------------------------------------

  def check_validation_changeset(running, which_changeset) do
    # Used throughout
    example_name = mockable(RunningExample).name(running)
    changeset = mockable(RunningExample).step_value!(running, which_changeset)
    
    # Check changeset valid field
    workflow_name = mockable(RunningExample).workflow_name(running)
    run_validity_assertions(workflow_name, example_name, changeset)

    # User checks
    user_checks = mockable(RunningExample).validation_changeset_checks(running)
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

  defp run_validity_assertions(workflow_name, example_name, changeset) do
    {assertion, error_snippet} =
      if workflow_name == :validation_error,
        do:   {Assertions.from(:invalid), "an invalid"},
        else: {Assertions.from(:valid), "a valid"}

    message =
      "Example `#{inspect example_name}`: workflow `#{inspect workflow_name}` expects #{error_snippet} changeset"
    adjust_assertion_message(
      fn ->
        assertion.(changeset)
      end,
      fn _ -> message end)
  end

  defp run_user_checks(checks, example_name, changeset) do
    checks
    |> Assertions.from
    |> run_assertions(changeset, example_name)
  end

  defp run_assertions(assertions, changeset, name) do
    adjust_assertion_message(
      fn ->
        for a <- assertions, do: a.(changeset)
      end,
      fn message ->
          """
          "Example `#{inspect name}`: #{message}"
          Changeset: #{inspect changeset}
          """
      end)
  end

  
  # ----------------------------------------------------------------------------

  def insert(running, which_changeset) do
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
          context__2(name, "unexpected insertion failure"),
          left: wrong)
    end
  end
  
  def check_constraint_changeset(running, which_changeset) do
    case RunningExample.step_value!(running, which_changeset) do
      {:error, changeset} -> 
        check_constraint_changeset_(changeset, running)
      tuple -> 
        elaborate_flunk(
          context(running.example, "Expected an error tuple containing a changeset"),
          left: tuple)
    end
  end

  def check_constraint_changeset__2(running, which_changeset) do
    error_case(running,
      mockable(RunningExample).step_value!(running, which_changeset))
  end

  defp error_case(running, {:error, changeset}) do
    example_name = mockable(RunningExample).name(running)

    # Just user checks for constraint errors
    user_checks = mockable(RunningExample).constraint_changeset_checks(running)
    run_user_checks(user_checks, example_name, changeset)
    
    :uninteresting_result
  end

  defp error_case(running, other) do
    name = mockable(RunningExample).name(running)
    elaborate_flunk(
      context__2(name, "expected an error tuple containing a changeset"),
      left: other)
  end

  # ----------------------------------------------------------------------------

  defchain check_constraint_changeset_(changeset, running) do
    prior_work = Keyword.get(running.history, :previously, %{})
    adjust_assertion_message(
      fn ->
        for check <- ChangesetChecks.get_constraint_checks(running.example, previously: prior_work),
          do: apply_assertion(changeset, check)
      end,
      fn message ->
        error_message(running.example, changeset, message)
      end)
  end
  defp apply_assertion(changeset, {:__custom_changeset_check, f}),
    do: f.(changeset)
  
  defp apply_assertion(changeset, {check_type, arg}),
    do: apply ChangesetA, assert_name(check_type), [changeset, arg]
  
  defp apply_assertion(changeset, check_type),
    do: apply ChangesetA, assert_name(check_type), [changeset]
  
  defp assert_name(check_type),
    do: "assert_#{to_string check_type}" |> String.to_atom

  # ----------------------------------------------------------------------------
  
  defp context(example, message),
    do: "Example `#{inspect Example.name(example)}`: #{message}."

  defp error_message(example, changeset, message) do
    """
    #{context(example, message)}
    Changeset: #{inspect changeset}
    """
  end

  defp context__2(name, message),
    do: "Example `#{inspect name}`: #{message}"

  defp error_message__2(name, changeset, message) do
    """
    #{context__2(name, message)}
    Changeset: #{inspect changeset}
    """
  end
end
