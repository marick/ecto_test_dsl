defmodule TransformerTestSupport.VariantSupport.ChangesetSupport do
  alias TransformerTestSupport.SmartGet.{Example,ChangesetChecks}
  import FlowAssertions.Define.{Defchain, BodyParts}
  use FlowAssertions.Ecto
  alias FlowAssertions.Ecto.ChangesetA
  alias Ecto.Changeset
  alias TransformerTestSupport.Runner

  def accept_params(example) do
    params = Example.params(example)
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

  def setup(history, example) do
    repo_examples = Keyword.get(history, :repo_setup, %{})
    
    Map.get(example, :setup, [])
    |> Enum.reduce(repo_examples, &(Map.merge(&2, setup_helper(&1, example, &2))))
  end

  defp setup_helper({:insert, extended_example_name_list}, to_help_example, so_far)
  when is_list(extended_example_name_list) do
    extended_example_name_list
    |> Enum.reduce(%{}, fn extended_example_name, acc ->
         one = setup_helper({:insert, extended_example_name}, to_help_example, so_far)
         Map.merge(acc, one)
       end)
  end

  defp setup_helper({:insert, extended_example_name}, to_help_example, so_far) do
    unless_already_present(extended_example_name, so_far, fn ->
      workflow_results = 
        Example.examples_module(to_help_example)
        |> Example.get(extended_example_name)
        |> Runner.run_example_steps(previously: so_far)

      dependently_created = Keyword.get(workflow_results, :repo_setup)
      {:ok, insert_result} = Keyword.get(workflow_results, :insert_changeset)
      
      Map.put(dependently_created, extended_example_name, insert_result)
    end)
  end

  defp unless_already_present(extended_example_name, so_far, f) do 
    if Map.has_key?(so_far, extended_example_name), do: so_far, else: f.()
  end

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
