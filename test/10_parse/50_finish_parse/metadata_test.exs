defmodule Parse.FinishParse.MetadataTest do
  use EctoTestDSL.Case
  use T.Predefines
  use T.Parse.Exports
  alias T.Parse.FinishParse
  alias T.Parse.BuildState

  defmodule Examples do
    use Template.Trivial
  end

  test "metadata propagation" do
    Examples.started()
    workflow(:workflow, example: [params(age: 1)])

    test_data = 
      BuildState.current
      |> FinishParse.finish

    metadata =
      test_data
      |> TestData.example(:example)
      |> Map.get(:metadata)

    metadata
    |> assert_fields(workflow_name: :workflow,
                     name: :example,
                     api_module: :irrelevant_api_module,
                     variant: T.Variants.Trivial)
    |> refute_field(:examples)   # Let's not get infinitely recursive
  end
end
