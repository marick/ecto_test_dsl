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
      add_one(acc, example, field)
    end)
  end

  defp add_one(changeset_checks, example, {field, {:__on_success, f, arg_template}}) do
    checker = fn changeset ->
      args = [changeset.changes[:date_string]]
      expected = apply(f, args)
      elaborate_assert(
        changeset.changes[field] == expected,
        "Changeset field `#{inspect field}` (left) does not match the value calculated from #{inspect f}#{inspect arg_template}",
        left: changeset.changes[field],
        right: expected)
      :ok
    end

    changeset_checks ++ [{:custom_changeset_check, checker}]
  end
end
