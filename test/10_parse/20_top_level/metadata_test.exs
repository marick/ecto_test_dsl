defmodule Parse.TopLevel.MetadataTest do
  use TransformerTestSupport.Case
  use T.Predefines
  use T.Parse.All
  alias T.Parse.TopLevel

  defmodule Examples do
    use Template.Trivial
  end

  test "metadata propagation" do
    test_data = 
      Examples.started()
      |> workflow(:workflow, example: [params(age: 1)])
      |> TopLevel.propagate_metadata

    metadata =
      test_data
      |> TestData.example(:example)
      |> Map.get(:metadata)

    metadata
    |> assert_fields(workflow_name: :workflow,
                     name: :example,
                     module_under_test: :irrelevant_module_under_test,
                     variant: T.Variants.Trivial)
    |> refute_field(:examples)   # Let's not get infinitely recursive
  end
end
