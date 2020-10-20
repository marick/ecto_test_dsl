defmodule TransformerTestSupport.Impl.SmartGet.ChangesetChecks.Validity do
    
  @moduledoc """
  """

  def add(changeset_checks, example) do
    if example.metadata.category_name == :validation_failure,
      do:   [:invalid | changeset_checks],
      else: [  :valid | changeset_checks]
  end
end
