defmodule Definitions.Changeset.Validation do
  alias App.Schemas.Basic, as: Schema
  use TransformerTestSupport.Variants.Changeset

  build(
    module_under_test: Schema,
    examples: [
      # -------------------------------------------VALID-------------------
      ok: %{
        params: to_strings(
          lock_version: 1,
          date: "2001-01-01"),
        changes: [lock_version: 1, date: ~D[2001-01-01]],
        categories: [:valid],
      },
      error: %{
        params: like(:ok, except: [date: "1-1-1"]),
        categories: [:invalid],
      }
    ])
end

