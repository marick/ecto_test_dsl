defmodule TransformerTestSupport.Impl.SmartGet.ChangesetChecks do
  alias TransformerTestSupport.Impl.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
    
  @moduledoc """
  """

  def get(example) do
    changeset_checks = Map.get(example, :changeset, [])
    user_mentioned = Checks.Util.unique_fields(changeset_checks)

    [as_cast_fields, calculated_fields] =
      Checks.Util.transformations(example)
      |> Enum.map(&(Checks.Util.remove_fields_named_by_user(&1, user_mentioned)))

    changeset_checks
    |> Checks.Validity.add(example)
    |> Checks.AsCast.add(example, as_cast_fields)
    |> Checks.Calculated.add(example, calculated_fields)
  end

  def get(test_data, example_name) do
    Example.get(test_data, example_name)
    |> get
  end
end
