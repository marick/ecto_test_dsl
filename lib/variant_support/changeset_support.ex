defmodule TransformerTestSupport.VariantSupport.ChangesetSupport do
  alias TransformerTestSupport, as: T
  alias T.SmartGet.{Example,ChangesetChecks}
  alias T.VariantSupport.ChangesetSupport.Setup
  import FlowAssertions.Define.{Defchain, BodyParts}
  use FlowAssertions.Ecto
  alias FlowAssertions.Ecto.ChangesetA
  alias Ecto.Changeset

  def accept_params(example, prior_work) do
    params = Example.params(example, previously: prior_work)
    module = Example.module_under_test(example)
    empty = struct(module)
    module.changeset(empty, params)
  end

  def check_validation_changeset(changeset, example),
    do: check_changeset(changeset, example, :changeset_for_validation_step)
  
  # ----------------------------------------------------------------------------

  # I can't offhand think of any case where one `setup` might need to
  # use the results of another that isn't part of the same dependency tree.
  # That might change if I add a category-wide or test-data-wide setup.

  # If that is done, the history must be passed in by `Runner.run_example_steps`

  def start_sandbox(example) do
    alias Ecto.Adapters.SQL.Sandbox

    repo = Example.repo(example)
    if repo do  # Convenient for testing, where we might be faking the repo functions.
      Sandbox.checkout(repo) # it's OK if it's already checked out.
    end
  end

  def setup(example, prior_work) do
    sources = Map.get(example, :setup, [])
    Setup.from_a_list(sources, example, prior_work)
  end

  # ----------------------------------------------------------------------------

  def insert(%Changeset{} = changeset, example) do
    repo = Example.repo(example)
    repo.insert(changeset)
  end
    

  def check_insertion_result({:ok, _result}, _example),
    do: :ok

  def check_insertion_result({:error, changeset}, example) do 
    elaborate_flunk(
      error_message(example, changeset, "Unexpected insertion failure"),
      left: changeset.errors)
  end

  def check_constraint_changeset({:error, changeset}, example),
    do: check_changeset(changeset, example, :changeset_for_constraint_step)

  def check_constraint_changeset(result, example) do 
    elaborate_flunk(
      context(example, "Expected an error tuple containing a changeset"),
      left: result)
  end

  # ----------------------------------------------------------------------------

  defchain check_changeset(changeset, example, step) do
    adjust_assertion_message(
      fn ->
        for check <- ChangesetChecks.get(example, step),
          do: apply_assertion(changeset, check)
      end,
      fn message ->
        error_message(example, changeset, message)
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
