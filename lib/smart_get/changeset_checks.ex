defmodule TransformerTestSupport.SmartGet.ChangesetChecks do
  use TransformerTestSupport.Drink.Me
  alias T.SmartGet.Example
  alias T.SmartGet.ChangesetChecks, as: Checks
  alias T.Link.FieldCalculation
    
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
    |> FieldCalculation.add(example, calculated_fields)
  end

  defp add_whole_changeset_check(checks_so_far, example) do
    if Example.workflow_name(example) == :validation_error,
      do:   [:invalid | checks_so_far],
      else: [  :valid | checks_so_far]
  end


  # ----------------------------------------------------------------------------

  # Note: there's not yet a reason for constraint changesets to
  # refer to previous examples.
  def get_constraint_checks(example, opts \\ []) do
    _previously = Keyword.get(opts, :previously, %{})
    changeset_checks = Map.get(example, :changeset_for_constraint_step, [])

    changeset_checks
  end
end
