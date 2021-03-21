defmodule Parse.TopLevel.FieldTransformationsTest do
  use EctoTestDSL.Case
  use T.Predefines
  use T.Parse.Exports
  alias T.Nouns.{AsCast,FieldCalculator}

  @empty %{
    api_module: Schema,
    as_cast: AsCast.nothing,
    field_calculators: []
  }

  describe "as_cast" do 
    test "simple creation" do
      @empty
      |> field_transformations(as_cast: [:a])
      |> assert_field(as_cast: AsCast.new(Schema, [:a]))
    end

    test "more than one in a single field calculation" do
      @empty
      |> field_transformations(as_cast: [:a], as_cast: [:b])
      |> assert_field(as_cast: AsCast.new(Schema, [:a, :b]))
    end

    test "multiple field calculations" do
      @empty
      |> field_transformations(as_cast: [:a], as_cast: [:b])
      |> field_transformations(as_cast: [:b, :c])
      |> assert_field(as_cast: AsCast.new(Schema, [:a, :b, :b, :c]))
      # Note that duplicates aren't filtered out because they're harmless.
    end
  end

  describe "field_calculators" do 
    test "simple creation" do
      actual =
        @empty
        |> field_transformations(a: on_success(Date.from_iso8601!(:date_string)))
        |> Map.get(:field_calculators)

      expected_calculator = 
        %FieldCalculator{calculation: &Date.from_iso8601!/1,
                         args: [:date_string],
                         from: "on_success(Date.from_iso8601!(:date_string))"}

      assert actual == [a: expected_calculator]
    end

    test "duplication is rejected" do
      assertion_fails("Keyword list should not have duplicate keys",
        fn -> 
          field_transformations(@empty, 
            a: on_success(Date.from_iso8601!(:date_string)),
            a: on_success(Date.from_iso8601(:date_string)))
        end)
    end

    test "But (so far) it's ok to have duplication in successive lists" do
      # Maybe this means user wants to write functions that supply
      # field transformations, and wants ability to have one function
      # "inherit and override" from another.
      actual =
        @empty
        |> field_transformations(a: on_success(Date.from_iso8601!(:date_string)))
        |> field_transformations(a: on_success(to_string(:intval)))

      expected = [a: on_success(to_string(:intval))]
      assert actual.field_calculators == expected
    end
  end

  test "both" do
    %{as_cast: as_cast, field_calculators: [b: field_calculator]} = 
      @empty
      |> field_transformations(as_cast: [:a], b: on_success(to_string(:int)))
    
    assert as_cast == AsCast.new(Schema, [:a])
    assert field_calculator.args == [:int]
  end
end
