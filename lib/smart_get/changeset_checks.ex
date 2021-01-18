defmodule TransformerTestSupport.SmartGet.ChangesetChecks do
  use TransformerTestSupport.Drink.Me
    
  @moduledoc """
  """


  # ----------------------------------------------------------------------------

  # Note: there's not yet a reason for constraint changesets to
  # refer to previous examples.
  def get_constraint_checks(example, opts \\ []) do
    _previously = Keyword.get(opts, :previously, %{})
    example_specific_checks = Map.get(example, :constraint_changeset_checks, [])

    example_specific_checks
  end
end
