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
      Examples.start(module_under_test: SomeSchema)
      |> workflow(:valid, ok: [params(age: 1)])
      |> TopLevel.propagate_metadata

    metadata =
      test_data
      |> SmartGet.Example.get(:ok)
      |> Map.get(:metadata)

    metadata
    |> assert_fields(workflow_name: :valid,
                     name: :ok,
                     module_under_test: SomeSchema,
                     variant: T.Variants.Trivial)
    |> refute_field(:examples)   # Let's not get infinitely recursive
  end
end
