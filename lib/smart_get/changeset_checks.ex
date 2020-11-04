defmodule TransformerTestSupport.SmartGet.ChangesetChecks do
  alias TransformerTestSupport.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
    
  @moduledoc """
  """

  def get(example, step) do
    changeset_checks = Map.get(example, step, [])
    user_mentioned = Checks.Util.unique_fields(changeset_checks)

    [as_cast_fields, calculated_fields] =
      Checks.Util.transformations(example)
      |> Enum.map(&(Checks.Util.remove_fields_named_by_user(&1, user_mentioned)))

    changeset_checks
    |> Checks.Validity.add(example, step)
    |> Checks.AsCast.add(example, as_cast_fields)
    |> Checks.Calculated.add(example, calculated_fields)
  end

  def get(test_data, example_name, step) do
    Example.get(test_data, example_name)
    |> get(step)
  end
end
