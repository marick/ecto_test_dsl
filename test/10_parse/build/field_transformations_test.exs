defmodule Build.FieldTransformationsTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  use T.Predefines
  alias T.Build
  alias T.Nouns.AsCast

  @empty %{module_under_test: Schema, as_cast: AsCast.nothing}

  describe "as_cast" do 
    test "simple creation" do
      @empty
      |> Build.field_transformations(as_cast: [:a])
      |> assert_field(as_cast: AsCast.new(Schema, [:a]))
    end

    test "more than one in a single field calculation" do
      @empty
      |> Build.field_transformations(as_cast: [:a], as_cast: [:b])
      |> assert_field(as_cast: AsCast.new(Schema, [:a, :b]))
    end

    test "multiple field calculations" do
      @empty
      |> Build.field_transformations(as_cast: [:a], as_cast: [:b])
      |> Build.field_transformations(as_cast: [:b, :c])
      |> assert_field(as_cast: AsCast.new(Schema, [:a, :b, :b, :c]))
      # Note that duplicates aren't filtered out because they're harmless.
    end
  end
end
