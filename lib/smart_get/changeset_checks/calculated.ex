defmodule TransformerTestSupport.SmartGet.ChangesetChecks.Calculated do
  alias TransformerTestSupport.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
  alias Ecto.Changeset
  import ExUnit.Assertions
  import FlowAssertions.Define.BodyParts
  
  @moduledoc """
  """

  

  def add(changeset_checks, example, fields) do
    Enum.reduce(fields, changeset_checks, fn field, acc ->
      maybe_add_one(acc, example, field)
    end)
  end

  defp maybe_add_one(changeset_checks, example, check_description) do
    case example.metadata.category_name do
      :validation_error ->
        changeset_checks
      _ ->
        add_one(changeset_checks, check_description)
    end
  end

  defp add_one(changeset_checks, {field, {:__on_success, f, arg_template}}) do 
    checker = fn changeset ->
      args = Enum.map(arg_template, &(translate_arg &1, changeset))
      expected = apply(f, args)
      elaborate_assert(
        changeset.changes[field] == expected,
        "Changeset field `#{inspect field}` (left) does not match the value calculated from #{inspect f}#{inspect arg_template}",
        left: changeset.changes[field],
        right: expected)
      :ok
    end
    changeset_checks ++ [{:__custom_changeset_check, checker}]
  end

  defp translate_arg(arg, changeset) when is_atom(arg), do: changeset.changes[arg]
  defp translate_arg(arg, changeset),                   do:                   arg
end
