defmodule TransformerTestSupport.SmartGet.ChangesetChecks do
  use TransformerTestSupport.Drink.Me
  alias T.Run.ChangesetChecks, as: CC
  alias T.Neighborhood.FieldCalculation
  alias T.Nouns.AsCast
  alias T.Run.RunningExample
    
  @moduledoc """
  """

  def get_validation_checks(running) do
    example = running.example
    example_specific_checks = Map.get(example, :validation_changeset_checks, [])
    user_mentioned = CC.unique_fields(example_specific_checks)

    resolved_params = RunningExample.expanded_params(running)

    with_valid = 
      whole_changeset_check(running)

    as_cast_checks =
      RunningExample.metadata(running, :as_cast)
      |> AsCast.subtract(user_mentioned)
      |> AsCast.changeset_checks(resolved_params)

    calculated_checks = 
      RunningExample.metadata(running, :field_calculators)
      |> FieldCalculator.subtract(user_mentioned)
      |> FieldCalculation.changeset_checks(example)

    (with_valid ++ example_specific_checks ++ as_cast_checks ++ calculated_checks)
  end

  defp whole_changeset_check(running) do
    if RunningExample.workflow_name(running) == :validation_error,
      do:   [:invalid],
      else: [:valid]
  end


  # ----------------------------------------------------------------------------

  # Note: there's not yet a reason for constraint changesets to
  # refer to previous examples.
  def get_constraint_checks(example, opts \\ []) do
    _previously = Keyword.get(opts, :previously, %{})
    example_specific_checks = Map.get(example, :constraint_changeset_checks, [])

    example_specific_checks
  end
end
