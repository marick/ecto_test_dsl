defmodule TransformerTestSupport.SmartGet.ChangesetChecks do
  use TransformerTestSupport.Drink.Me
  alias T.SmartGet.Example
  alias T.SmartGet.ChangesetChecks, as: Checks
  alias T.Neighborhood.Params
  alias T.Run.ChangesetChecks, as: CC
  alias T.Neighborhood.FieldCalculation
  alias T.Nouns.AsCast
    
  @moduledoc """
  """

  def get_validation_checks(example, previously: previously) do
    example_specific_checks = Map.get(example, :changeset_for_validation_step, [])
    user_mentioned = CC.unique_fields(example_specific_checks)

    resolved_params = Params.get(example, previously: previously)

    with_valid = 
      add_whole_changeset_check([], example)

    as_cast_checks =
      Example.metadata!(example, :as_cast)
      |> AsCast.subtract(user_mentioned)
      |> AsCast.changeset_checks(resolved_params)

    calculated_fields = 
      Example.metadata!(example, :field_calculators)
      |> Enum.reject(&Enum.member?(user_mentioned, &1))

    calculated_checks = 
      FieldCalculation.add([], example, calculated_fields)


    (with_valid ++       example_specific_checks
      ++ as_cast_checks ++ calculated_checks)
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
    example_specific_checks = Map.get(example, :changeset_for_constraint_step, [])

    example_specific_checks
  end
end
