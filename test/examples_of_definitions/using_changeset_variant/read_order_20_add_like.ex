defmodule Definitions.Changeset.AddLike do
  alias App.Schemas.Basic, as: Schema
  use TransformerTestSupport.Variants.Changeset

  @test_data build(
    module_under_test: Schema,
    exemplars: [
      # -------------------------------------------VALID-------------------
      valid: %{
        params: to_strings(
          lock_version: 1,
          date: "2001-01-01"), 
      },
      invalid: %{
        params: like(:valid, except: [date: "1-1-1"])
      }
    ])

  def test_data(), do: @test_data
end

