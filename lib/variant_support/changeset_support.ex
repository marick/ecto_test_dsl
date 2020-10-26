defmodule TransformerTestSupport.VariantSupport.Changeset do

  defmacro __using__(_) do
    quote do
      import FlowAssertions.Define.{Defchain,BodyParts}
      import ExUnit.Assertions
      use FlowAssertions.Ecto
      alias TransformerTestSupport.Get
      alias TransformerTestSupport.SmartGet
      alias FlowAssertions.Ecto.ChangesetA

     def accept_params(%{module_under_test: module} = test_data, example_name) do
       params = SmartGet.Params.get(test_data, example_name)
       module.changeset(struct(module), params)
     end
     
     defchain check_validation_changeset(changeset, test_data, example_name) do
       example = SmartGet.Example.get(test_data, example_name)
       
       adjust_assertion_message(
         fn ->
           try_assertions(changeset, example_name, example)
         end,
         fn message ->
           """
           Example `#{inspect example_name}`: #{message}
           Changeset: #{inspect changeset}
           """
         end)
     end
     
     def check_everything(test_data, example_name) do
       changeset = accept_params(test_data, example_name)
       check_validation_changeset(changeset, test_data, example_name)
     end
     
     # ----------------------------------------------------------------------------
     
     
     defp try_assertions(changeset, _example_name, example) do
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
    end
  end
end
