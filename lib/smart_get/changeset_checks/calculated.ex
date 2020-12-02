defmodule TransformerTestSupport.SmartGet.ChangesetChecks.Calculated do
  alias TransformerTestSupport.SmartGet.Example
  import FlowAssertions.Define.BodyParts
  import ExUnit.Assertions
  
  @moduledoc """
  """

  def add(changeset_checks, example, fields) do
    Enum.reduce(fields, changeset_checks, fn field, acc ->
      maybe_add_one(acc, example, field)
    end)
  end

  defp maybe_add_one(changeset_checks, example, check_description) do
    case Example.workflow_name(example) do
      :validation_error ->
        changeset_checks
      _ ->
        add_one(changeset_checks, check_description)
    end
  end

  defp add_one(changeset_checks, {field, {:__on_success, f, arg_template}}) do 
    checker = fn changeset ->
      if function_is_relevant?(arg_template, changeset) do
        add_one_relevant(changeset, field, f, arg_template)
      else
        :ok
      end
    end
    changeset_checks ++ [{:__custom_changeset_check, checker}]
  end

  def add_one_relevant(changeset, field, f, arg_template) do
    args = Enum.map(arg_template, &(translate_arg &1, changeset))
    transformer_spec = "#{inspect f}#{inspect arg_template}"

    unless Map.has_key?(changeset.changes, field) do
      flunk("The changeset has all the prerequisites to calculate `#{inspect field}` (using #{transformer_spec}), but `#{inspect field}` is not in the changeset's changes")
    end
    
    expected = 
      try do
        apply(f, args)
      rescue
        ex ->
          exception_name = inspect ex.__struct__
          elaborate_flunk("#{exception_name} was raised when field transformer #{transformer_spec} was applied to #{inspect args}",
            [left: Exception.format(:error, ex)])
      end
    elaborate_assert(
      changeset.changes[field] == expected,
      "Changeset field `#{inspect field}` (left) does not match the value calculated from #{transformer_spec}",
      left: changeset.changes[field],
      right: expected)
    :ok
  end

  defp function_is_relevant?(arg_template, changeset) do
    Enum.all?(arg_template, fn one ->
      cond do
        not is_atom(one) -> true
        Map.has_key?(changeset.changes, one) -> true
        :else -> false
      end
    end)
  end

  defp translate_arg(arg,  changeset) when is_atom(arg), do: changeset.changes[arg]
  defp translate_arg(arg, _changeset),                   do:                   arg
end
