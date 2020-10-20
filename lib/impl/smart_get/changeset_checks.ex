defmodule TransformerTestSupport.Impl.SmartGet.ChangesetChecks do
  alias TransformerTestSupport.Impl.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
    
  @moduledoc """
  """

  def get(example) do
    changeset_checks = Map.get(example, :changeset, [])
    user_mentioned = Checks.Util.unique_fields(changeset_checks)

    changeset_checks
    |> Checks.Validity.add(example)
    |> Checks.AsCast.add(example, user_mentioned)
  end

  def get(test_data, example_name) do
    Example.get(test_data, example_name)
    |> get
  end
end
