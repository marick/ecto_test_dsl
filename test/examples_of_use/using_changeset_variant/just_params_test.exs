defmodule App.Schemas.Basic.JustParamsTest do
  use TransformerTestSupport.Case
  alias App.Schemas.Basic, as: Schema
  alias Definitions.Changeset.JustParams, as: Params

  test "valid dates are accepted" do
    Schema.changeset(%Schema{}, Params.params(:ok))
    |> assert_valid
    |> assert_changes(lock_version: 1,
                      date: ~D[2001-01-01])
  end

  test "invalid dates are rejected" do
    Schema.changeset(%Schema{}, Params.params(:error))
    |> assert_invalid
    |> assert_error(date: "is invalid")
  end
end
