defmodule Variants.EctoClassic.CategoryAdjustmentTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Variants.EctoClassic
  import FlowAssertions.AssertionA
#  import FlowAssertions.Define.Tabular

  describe "modifications" do
    test "prepend to existing changeset assertions" do
      example = %{changeset: [changes: [field: "value"]]}
      actual = EctoClassic.run_example_hook(example, :valid)

      assert actual == %{changeset: [:valid, changes: [field: "value"]]}
    end

    test "create a validity assertion" do
      example = %{}
      actual = EctoClassic.run_example_hook(example, :invalid)

      assert actual == %{changeset: [:invalid]}
    end

    test "a map is acceptable" do 
      example = %{changeset: %{changes: [field: "value"]}}
      actual = EctoClassic.run_example_hook(example, :valid)

      assert actual == %{changeset: [:valid, changes: [field: "value"]]}
    end
  end

  test "bad categories are flagged" do
    assertion_fails(
      ~r/only allows these categories/,
      [left: :broken],
      fn -> 
        EctoClassic.run_example_hook(%{}, :broken)
      end)
  end
end
