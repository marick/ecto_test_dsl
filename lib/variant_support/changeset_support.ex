defmodule TransformerTestSupport.VariantSupport.Changeset do
  alias TransformerTestSupport.SmartGet
  import FlowAssertions.Define.{Defchain, BodyParts}
  use FlowAssertions.Ecto
  alias FlowAssertions.Ecto.ChangesetA

  def accept_params(example) do
    params = SmartGet.Params.get(example)
    module = example.metadata.module_under_test
    empty = struct(module)
    module.changeset(empty, params)
  end

  # ----------------------------------------------------------------------------
  
  def check_validation_changeset(changeset, example) do
    adjust_assertion_message(
      fn ->
        assert_all_assertions(changeset, example)
      end,
      fn message ->
        error_message(example, changeset, message)
      end)
  end

  defchain assert_all_assertions(changeset, example) do
    for check <- SmartGet.ChangesetChecks.get(example),
      do: apply_assertion(changeset, check)
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

  def check_insertion_result({:ok, _result}, _example),
    do: :ok

  def check_insertion_result({:error, changeset}, example) do 
    elaborate_flunk(
      error_message(example, changeset, "Unexpected insertion failure"),
      left: changeset.errors)
  end

  def check_constraint_changeset({:error, _result}, _example) do
    
  end

  def check_constraint_changeset(result, example) do 
    elaborate_flunk(
      context(example, "Expected an error tuple containing a changeset"),
      left: result)
  end

  # ----------------------------------------------------------------------------

  def context(example, message),
    do: "Example `#{inspect example.metadata.name}`: #{message}."

  def error_message(example, changeset, message) do
    """
    #{context(example, message)}
    Changeset: #{inspect changeset}
    """
  end
end
