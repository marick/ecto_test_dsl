defmodule TransformerTestSupport.SmartGet.ChangesetChecks.Validity do
  alias TransformerTestSupport.SmartGet.Example
    
  @moduledoc """
  """

  def add(changeset_checks, example) do
    if Example.category_name(example) in [:validation_error, :constraint_error],
      do:   [:invalid | changeset_checks],
      else: [  :valid | changeset_checks]
  end
end
