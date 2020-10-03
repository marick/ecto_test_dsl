defmodule Impl.ValidationsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Validations
  import FlowAssertions.AssertionA

  test "validate_categories actually calls the validator" do
    test_data =
      %{examples: %{
           used: %{params: %{name: "used"},
                   categories: [:used_category]},
           unused: %{categories: [:unused_category]}
        }}

    assertion_fails("called `:used`",
      fn ->
        Validations.validate_categories(test_data, [:used_category],
          fn name -> flunk("called `#{inspect name}`") end)
      end)
  end


  @tag :skip
  test "require an example to have a category."

  
end
