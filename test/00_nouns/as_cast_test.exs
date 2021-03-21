defmodule Nouns.AsCastTest do
  use EctoTestDSL.Case
  alias T.Nouns.AsCast

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
      AsCast.new(cast_fields)
      |> AsCast.changeset_checks(Schema, params)
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
      AsCast.new([:int_field])
      |> AsCast.assertions(Schema, %{"int_field" => "383"})

    wrapped_location = [{:changeset, [{:changes, [int_field: 383]}, "..."]}]
    additional_context = [as_cast: [:int_field]]

    assertion_fails("Field `:int_field` has the wrong value",
      [left: 384, right: 383,
       expr: [additional_context, "expanded to", wrapped_location]],
      fn ->
        ChangesetX.valid_changeset(changes: %{int_field: 384}) |> assertion.()
      end)
  end


  test "there is a null AsCast value" do
    AsCast.nothing()
    |> AsCast.changeset_checks(Schema, %{"date_string" => "irrelevant"})
    |> assert_equal([])
  end

  test "merging" do
    AsCast.nothing
    |> AsCast.merge(AsCast.new([:a]))
    |> assert_fields(field_names: [:a])
    |> AsCast.merge(AsCast.new([:b]))
    |> assert_fields(field_names: [:a, :b])
  end

  test "subtracting field names" do
    AsCast.new([:a, :b, :c])
    |> AsCast.subtract([:b, :c, :d])
    |> assert_fields(field_names: [:a])
  end
end 
