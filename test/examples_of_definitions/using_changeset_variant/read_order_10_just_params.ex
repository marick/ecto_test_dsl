defmodule Definitions.Changeset.JustParams do
  alias App.Schemas.Basic, as: Schema
  use TransformerTestSupport.Variants.Changeset

  defp create_test_data do 
    build(
      module_under_test: Schema,
      exemplars: [
        # -------------------------------------------VALID-------------------
        valid: %{
          params: to_strings(
            lock_version: 1,
            date: "2001-01-01"), 
        },
        invalid: %{
          params: to_strings(
            lock_version: 1,
            date: "1-1-1"),
        }
      ])
  end
end

