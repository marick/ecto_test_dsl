defmodule TransformerTestSupport.SmartGet.ChangesetChecks.Calculated do
  alias TransformerTestSupport.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
  alias Ecto.Changeset
    
  @moduledoc """
  """

  

  def add(changeset_checks, example, fields) do
    Enum.reduce(fields, changeset_checks, fn field, acc ->
      add_one(acc, example, field)
    end)
  end

  defp add_one(changeset_checks, example, {field, {:__on_success, f, args}} = x) do
    changeset_checks
  end
end
