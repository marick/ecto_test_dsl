defmodule Nouns.AsCastTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  alias T.Nouns.AsCast

  defmodule Association do
    use Ecto.Schema

    schema "association" do 
      field :value, :integer
    end
  end

  defmodule Struct do
    use Ecto.Schema

    schema "struct" do 
      field :int_field, :integer, virtual: true
      field :string_field, :string
      field :date_string, :string, virtual: true
      belongs_to :association_field, Association
    end
  end

  test "creating and checking" do
    expect = fn [cast_fields, params], ex_changes, ex_unchanged, ex_errors ->
      expected = [changes: ex_changes, no_changes: ex_unchanged, errors: ex_errors]
      AsCast.new(Struct, cast_fields)
      |> AsCast.changeset_checks(params)
      |> assert_equal(expected)
    end
      

    [[:int_field], %{"int_field" => "383"}]
                          |> expect.([int_field: 383], [], [])
    [[:int_field], %{                    }]
                          |> expect.([], [:int_field], [])
    [[:int_field], %{"int_field" => "foo"}]
                          |> expect.([], [:int_field], [int_field: "is invalid"])

    # A big example
    [[:int_field, :string_field, :association_field_id],
     %{"int_field" => "ape", "string_field" => "s", "association_field_id" => "8",
       "date_string" => "irrelevant", "extra_field" => "irrelevant"}
    ]
    |> expect.([association_field_id: 8, string_field: "s"],
               [:int_field],
               [int_field: "is invalid"])

    # The default error message is OK.
    assert_raise(ArgumentError, fn -> 
      [[:mistake], %{"int_field" => "383"}] |> expect.([int_field: 383], [], [])
    end)
  end

  test "there is a null AsCast value" do
    AsCast.nothing()
    |> AsCast.changeset_checks(%{"date_string" => "irrelevant"})
    |> assert_equal([])
  end


  test "merging" do
    AsCast.nothing
    |> AsCast.merge(AsCast.new(MyStruct, [:a]))
    |> assert_fields(module: MyStruct, field_names: [:a])
    |> AsCast.merge(AsCast.new(MyStruct, [:b]))
    |> assert_fields(module: MyStruct, field_names: [:a, :b])
  end
end 
