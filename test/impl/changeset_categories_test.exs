defmodule Impl.ChangesetCategoriesTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Variants.Changeset__2, as: Changeset
  import FlowAssertions.AssertionA
#  import FlowAssertions.Define.Tabular

  describe "category :valid (stands in for :invalid as well)" do
    test "prepend to existing changeset assertions" do
      example = %{changeset: [changes: [field: "value"]]}
      actual = Changeset.adjust_example(example, :valid)

      assert actual == %{changeset: [:valid, changes: [field: "value"]]}
    end

    test "create a validity assertion" do
      example = %{}
      actual = Changeset.adjust_example(example, :valid)

      assert actual == %{changeset: [:valid]}
    end

    test "a map is acceptable" do 
      example = %{changeset: %{changes: [field: "value"]}}
      actual = Changeset.adjust_example(example, :valid)

      assert actual == %{changeset: [:valid, changes: [field: "value"]]}
    end
  end

  test "bad categories are flagged" do
    assertion_fails(
      ~r/only allows these categories/,
      [left: :broken],
      fn -> 
        Changeset.adjust_example(%{}, :broken)
      end)
  end
end
