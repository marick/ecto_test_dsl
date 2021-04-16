defmodule Nouns.ChangesetAsCastTest do
  use EctoTestDSL.Case
  alias T.Nouns.AsCast
  alias T.Run.ChangesetAsCast

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
  test "creating and checking, part 1: changeset notation" do
    run = fn [cast_fields, params] ->
      AsCast.new(cast_fields)
      |> ChangesetAsCast.changeset_checks(Schema, params)
    end

    {expect, raises} = TabularA.runners(run)
    
    # expect = fn args, expected ->
    #   run.(args)
    #   |> assert_equal(expected)
    # end
      

    [[:int_field], %{"int_field" => "383"}] |> expect.(
                                                 [changes:    [int_field: 383]    ])
    [[:int_field], %{                    }] |> expect.(
                                                 [no_changes: [:int_field]        ])
    [[:int_field], %{"int_field" => "foo"}] |> expect.(
                                                 [no_changes: [:int_field         ],
                                                  errors: [int_field: "is invalid"]])
    
    [[:mistake], %{"int_field" => "383"}] |> raises.([ArgumentError,
                                                   ~r/unknown field `:mistake`/])
    # A big example
    [[:int_field, :string_field, :association_field_id],
     %{"int_field" => "ape", "string_field" => "s", "association_field_id" => "8",
       "date_string" => "irrelevant", "extra_field" => "irrelevant"}
    ]
    |> expect.([changes: [association_field_id: 8, string_field: "s"],
               no_changes: [:int_field],
               errors: [int_field: "is invalid"]])
  end

  test "creating and checking, part 2: assertions" do
    [assertion] = 
      AsCast.new([:int_field])
      |> ChangesetAsCast.assertions(Schema, %{"int_field" => "383"})

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
    |> ChangesetAsCast.changeset_checks(Schema, %{"date_string" => "irrelevant"})
    |> assert_equal([])
  end
end 
