defmodule Variants.PhoenixGranular.StartTest do
  use EctoTestDSL.Case
  use T.Predefines
  alias T.Variants.PhoenixGranular.Insert, as: Variant

  defmodule Examples do
    use Template.PhoenixGranular.Insert
  end

  @minimal_start [
    module_under_test: SomeSchema,
    repo: Repo
  ]
    
  test "has the usual fields" do
    metadata = Examples.start(@minimal_start)

    metadata
    |> assert_fields(
         format: :phoenix,
         module_under_test: SomeSchema,
         variant: Variant,
         examples: [],
         field_transformations: []
      )
  end
  
  test "fields are checked" do
    assertion_fails(~r/Required keys are missing/,
      fn ->
        Examples.start([]) 
      end)
  end
end
