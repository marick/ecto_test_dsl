defmodule Definitions.Changeset.AddLike do
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
      },
      error: %{
        params: like(:ok, except: [date: "1-1-1"])
      }
    ])
end

