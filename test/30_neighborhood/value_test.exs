defmodule Neighborhood.ValueTest do
  use EctoTestDSL.Case
  use T.Parse.Exports
  alias Neighborhood.Value

  defmodule Schema do
    defstruct [:age]
  end

  @example %{metadata: %{module_under_test: Schema}}

  test "neighborhood can contain inserted value" do
    # Note that the last-created value is taken

    inserted = %Schema{age: 3}
    
    [other: Date, irrelevant: inserted, later: %Schema{age: "wrong"},
     example: @example]
    |> Value.from_workflow_results
    |> assert_fields(inserted: inserted,
                     changeset: nil,
                     params: nil)
  end
  
  test "can capture params" do
    params = %{name: "Bossie", species_id: 334}
    [params: params, example: @example]
    |> Value.from_workflow_results
    |> assert_fields(inserted: nil,
                     changeset: nil,
                     params: params)
  end

  test "can capture the *oldest* changeset" do
    changeset = T.ChangesetX.valid_changes(name: "just_right")
    
    [too_new: T.ChangesetX.valid_changes(name: "too_new"),
     just_right: changeset, example: @example]
    |> Value.from_workflow_results
    |> assert_fields(inserted: nil,
                     changeset: changeset,
                     params: nil)
  end
end
