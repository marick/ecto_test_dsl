defmodule TransformerTestSupport.SmartGet.ChangesetChecks do
  alias TransformerTestSupport.SmartGet
  alias SmartGet.Example
  alias SmartGet.ChangesetChecks, as: Checks
    
  @moduledoc """
  """

  def get_validation_checks(example, previously: previously) do
    changeset_checks = Map.get(example, :changeset_for_validation_step, [])
    user_mentioned = Checks.Util.unique_fields(changeset_checks)

    [as_cast_fields, calculated_fields] =
      Checks.Util.separate_types_of_transformed_fields(example)
      |> Enum.map(&(Checks.Util.remove_fields_named_by_user(&1, user_mentioned)))

    changeset_checks
    |> add_whole_changeset_check(example)
    |> Checks.AsCast.add(example, previously, as_cast_fields)
    |> Checks.Calculated.add(example, calculated_fields)
  end

  IO.inspect "DELETE THIS"
  def get_validation_checks(test_data, example_name) do
    Example.get(test_data, example_name)
    |> get_validation_checks(previously: %{})
  end

  defp add_whole_changeset_check(checks_so_far, example) do
    if Example.category_name(example) == :validation_error,
      do:   [:invalid | checks_so_far],
      else: [  :valid | checks_so_far]
  end


  # ----------------------------------------------------------------------------


  def get_constraint_checks(example, previously: _previously) do
    changeset_checks = Map.get(example, :changeset_for_constraint_step, [])

    changeset_checks
  end

  def get_constraint_checks(test_data, example_name, step) do
    Example.get(test_data, example_name)
    |> get_constraint_checks(step, previously: %{})
  end
end
