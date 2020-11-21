defmodule ValidationsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Validations
  import FlowAssertions.AssertionA

  test "validate_categories actually calls the validator" do
    test_data =
      %{examples: %{
           used: %{params: %{name: "used"},
                   categories: [:used_workflow]},
           unused: %{categories: [:unused_workflow]}
        }}

    assertion_fails("called `:used`",
      fn ->
        Validations.validate_categories(test_data, [:used_workflow],
          fn name -> flunk("called `#{inspect name}`") end)
      end)
  end


  @tag :skip
  test "require an example to have a workflow."

  
end
