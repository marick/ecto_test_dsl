defmodule TransformerTestSupport.VariantSupport.ChangesetSupport do
  use TransformerTestSupport.Drink.Me
  alias T.SmartGet.{Example,ChangesetChecks,Params}
  alias T.VariantSupport.ChangesetSupport.Previously
  import FlowAssertions.Define.{Defchain, BodyParts}
  alias T.RunningExample
  use FlowAssertions.Ecto
  alias FlowAssertions.Ecto.ChangesetA
  alias T.RunningExample.Trace

  # Default functions

  def changeset_with__default_insert(module_under_test, params) do
    default_struct = struct(module_under_test)
    module_under_test.changeset(default_struct, params)
  end

  def insert_with__default(repo, changeset),
    do: repo.insert(changeset)
  

  # ----------------------------------------------------------------------------
  def params(running) do
    prior_work = Keyword.get(running.history, :previously, %{})
    params = Params.get(running.example, previously: prior_work)

    Trace.say(params, :params)
    params
  end
  
  def accept_params(%{history: history, example: example}) do
    params = Keyword.fetch!(history, :params)
    module = Example.module_under_test(example)
    apply Example.metadata!(example, :changeset_with), [module, params]
  end

  def check_validation_changeset(running, changeset_step) do 
    changeset = RunningExample.step_value!(running, changeset_step)
    check_validation_changeset_(changeset, running)
    :uninteresting_result
  end
  
  # ----------------------------------------------------------------------------

  # I can't offhand think of any case where one `previously` might need to
  # use the results of another that isn't part of the same dependency tree.
  # That might change if I add a workflowy-wide or test-data-wide setup.

  # If that is done, the history must be passed in by `RunningExample.run`

  def start_sandbox(example) do
    alias Ecto.Adapters.SQL.Sandbox

    repo = Example.repo(example)
    if repo do  # Convenient for testing, where we might be faking the repo functions.
      Sandbox.checkout(repo) # it's OK if it's already checked out.
    end
  end

  def previously(running) do
    prior_work = Keyword.get(running.history, :previously, %{})
    sources = Map.get(running.example, :previously, [])
    Previously.from_a_list(sources, running.example, prior_work)
  end

  # ----------------------------------------------------------------------------

  def insert(running, changeset_step) do
    changeset = RunningExample.step_value!(running, changeset_step)
    repo = Example.repo(running.example)
    apply Example.metadata!(running.example, :insert_with), [repo, changeset]
  end

  def check_insertion_result(running, insertion_step) do
    case RunningExample.step_value!(running, insertion_step) do
      {:ok, _result} -> 
        :uninteresting_result
      {:error, changeset} -> 
        elaborate_flunk(
          error_message(running.example, changeset, "Unexpected insertion failure"),
          left: changeset.errors)
    end
  end
  
  def check_constraint_changeset(running, changeset_step) do
    case RunningExample.step_value!(running, changeset_step) do
      {:error, changeset} -> 
        check_constraint_changeset_(changeset, running)
      tuple -> 
        elaborate_flunk(
          context(running.example, "Expected an error tuple containing a changeset"),
          left: tuple)
    end
  end


  # ----------------------------------------------------------------------------

  defchain check_validation_changeset_(changeset, running) do
    prior_work = Keyword.get(running.history, :previously, %{})
    adjust_assertion_message(
      fn ->
        for check <- ChangesetChecks.get_validation_checks(running.example, previously: prior_work),
          do: apply_assertion(changeset, check)
      end,
      fn message ->
        error_message(running.example, changeset, message)
      end)
  end

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
end
