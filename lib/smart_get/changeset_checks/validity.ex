defmodule TransformerTestSupport.SmartGet.ChangesetChecks.Validity do
  alias TransformerTestSupport.SmartGet.Example
    
  @moduledoc """
  """

  IO.inspect "DELETE THIS"

  def add(changeset_checks, example, step) do
    if expect_invalid?(step, Example.category_name(example)),
      do:   [:invalid | changeset_checks],
      else: [  :valid | changeset_checks]
  end


  defp expect_invalid?(:changeset_for_validation_step, category_name),
    do: category_name == :validation_error
  defp expect_invalid?(:changeset_for_constraint_step, category_name),
    do: category_name == :constraint_error
end
