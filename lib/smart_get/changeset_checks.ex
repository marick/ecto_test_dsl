defmodule TransformerTestSupport.SmartGet.ChangesetChecks do
  use TransformerTestSupport.Drink.Me
  alias T.SmartGet.Example
  alias T.SmartGet.ChangesetChecks, as: Checks
  alias T.Neighborhood.Params
  alias T.Run.ChangesetChecks, as: CC
  alias T.Neighborhood.FieldCalculation
  alias T.Nouns.AsCast
  alias T.Run.RunningExample
    
  @moduledoc """
  """

  def get_validation_checks(running) do
    previously = RunningExample.neighborhood(running)
    example = running.example
    example_specific_checks = Map.get(example, :changeset_for_validation_step, [])
    user_mentioned = CC.unique_fields(example_specific_checks)

    resolved_params = Params.get(example, previously: previously)

    with_valid = 
      whole_changeset_check(example)

    as_cast_checks =
      Example.metadata!(example, :as_cast)
      |> AsCast.subtract(user_mentioned)
      |> AsCast.changeset_checks(resolved_params)

    calculated_checks = 
      Example.metadata!(example, :field_calculators)
      |> FieldCalculator.subtract(user_mentioned)
      |> FieldCalculation.changeset_checks(example)

    (with_valid ++ example_specific_checks ++ as_cast_checks ++ calculated_checks)
  end

  defp whole_changeset_check(example) do
    if Example.workflow_name(example) == :validation_error,
      do:   [:invalid],
      else: [:valid]
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
