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
    # IO.inspect {changeset, example}
    example_name = example.metadata.name
    adjust_assertion_message(
      fn ->
        assert_all_assertions(changeset, example)
      end,
      fn message ->
        """
        Example `#{inspect example_name}`: #{message}
        Changeset: #{inspect changeset}
        """
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
  
end
