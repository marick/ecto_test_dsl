defmodule Variants.Changeset.CategoryAdjustmentTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Variants.Changeset
  import FlowAssertions.AssertionA
#  import FlowAssertions.Define.Tabular

  describe "modifications" do
    test "prepend to existing changeset assertions" do
      example = %{changeset: [changes: [field: "value"]]}
      actual = Changeset.run_example_hook(example, :valid)

      assert actual == %{changeset: [:valid, changes: [field: "value"]]}
    end

    test "create a validity assertion" do
      example = %{}
      actual = Changeset.run_example_hook(example, :invalid)

      assert actual == %{changeset: [:invalid]}
    end

    test "a map is acceptable" do 
      example = %{changeset: %{changes: [field: "value"]}}
      actual = Changeset.run_example_hook(example, :valid)

      assert actual == %{changeset: [:valid, changes: [field: "value"]]}
    end
  end

  test "bad categories are flagged" do
    assertion_fails(
      ~r/only allows these categories/,
      [left: :broken],
      fn -> 
        Changeset.run_example_hook(%{}, :broken)
      end)
  end
end
