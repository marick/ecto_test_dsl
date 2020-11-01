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

  def check_validation_changeset(changeset, example),
    do: check_changeset(changeset, example, :changeset_for_validation_step)
  
  # ----------------------------------------------------------------------------

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

  defchain check_changeset(changeset, example, purpose) do
    adjust_assertion_message(
      fn ->
        for check <- SmartGet.ChangesetChecks.get(example, purpose),
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
    do: "Example `#{inspect example.metadata.name}`: #{message}."

  defp error_message(example, changeset, message) do
    """
    #{context(example, message)}
    Changeset: #{inspect changeset}
    """
  end
end
