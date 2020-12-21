defmodule Nouns.AsCastTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  alias T.Nouns.AsCast
  alias T.Sketch

  defmodule Association do
    use Ecto.Schema

    schema "association" do 
      field :value, :integer
    end
  end

  defmodule Schema do
    use Ecto.Schema

    schema "struct" do 
      field :int_field, :integer, virtual: true
      field :string_field, :string
      field :date_string, :string, virtual: true
      belongs_to :association_field, Association
    end
  end

  # This generates `changeset` notation rather than assertions because
  # that's easier to examine.
  test "creating and checking, part 1" do
    expect = fn [cast_fields, params], expected ->
      AsCast.new(Schema, cast_fields)
      |> AsCast.changeset_checks(params)
      |> assert_equal(expected)
    end
      

    [[:int_field], %{"int_field" => "383"}]
                          |> expect.([changes: [int_field: 383]])
    [[:int_field], %{                    }]
                          |> expect.([no_changes: [:int_field]])
    [[:int_field], %{"int_field" => "foo"}]
                          |> expect.([no_changes: [:int_field],
                                     errors: [int_field: "is invalid"]])

    # A big example
    [[:int_field, :string_field, :association_field_id],
     %{"int_field" => "ape", "string_field" => "s", "association_field_id" => "8",
       "date_string" => "irrelevant", "extra_field" => "irrelevant"}
    ]
    |> expect.([changes: [association_field_id: 8, string_field: "s"],
               no_changes: [:int_field],
               errors: [int_field: "is invalid"]])

    # The default error message is OK.
    assert_raise(ArgumentError, fn -> 
      [[:mistake], %{"int_field" => "383"}] |> expect.([changes: [int_field: 383]])
    end)
  end

  test "creating and checking, part 2: assertions" do
    [assertion] = 
      AsCast.new(Schema, [:int_field])
      |> AsCast.assertions(%{"int_field" => "383"})

    assertion_fails("Field `:int_field` has the wrong value",
      [left: 384, right: 383],
      fn ->
        Sketch.valid_changeset(changes: %{int_field: 384}) |> assertion.runner.()
      end)
  end


  test "there is a null AsCast value" do
    AsCast.nothing()
    |> AsCast.changeset_checks(%{"date_string" => "irrelevant"})
    |> assert_equal([])
  end

  test "merging" do
    AsCast.nothing
    |> AsCast.merge(AsCast.new(Schema, [:a]))
    |> assert_fields(module: Schema, field_names: [:a])
    |> AsCast.merge(AsCast.new(Schema, [:b]))
    |> assert_fields(module: Schema, field_names: [:a, :b])
  end

  test "subtracting field names" do
    AsCast.new(Schema, [:a, :b, :c])
    |> AsCast.subtract([:b, :c, :d])
    |> assert_fields(module: Schema, field_names: [:a])
  end
end 
