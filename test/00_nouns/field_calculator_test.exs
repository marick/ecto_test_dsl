defmodule Nouns.FieldCalculatorTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  alias T.Nouns.FieldCalculator
  alias T.Sketch
  alias FlowAssertions.Define.Tabular
  import T.Build

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
      field :int_field_incremented, :integer
      
      field :date_string, :string, virtual: true
      field :date, :date

      belongs_to :association_field, Association
    end
  end

  test "creating" do
    inc = &(&1 + 1)

    FieldCalculator.new(inc, [:int_field])
    |> assert_fields(calculation: inc, args: [:int_field], from: "unknown")

    FieldCalculator.new(inc, [:int_field], "source")
    |> assert_fields(calculation: inc, args: [:int_field], from: "source")
    
  end

  describe "merging" do 
    test "success" do 
      start = []
      first = [a: FieldCalculator.new(&to_string/1, [:field])]
      
      assert FieldCalculator.merge(start, first) == first

      second = [b: FieldCalculator.new(&String.upcase/1, [:other])]
      assert FieldCalculator.merge(first, second) == first ++ second
    end

    test "duplicate keys: ok if other fields are identical (via `==`)" do
      only = [a: FieldCalculator.new(&to_string/1, [:field])]
      assert FieldCalculator.merge(only, only) == only
    end

    test "duplicate keys: bad if either value is wrong" do
      inc = &(&1 + 1)
      template = FieldCalculator.new(inc,          [:field])
      bad_func = FieldCalculator.new(&to_string/1, [:field])
      bad_args = FieldCalculator.new(inc,          [:field, :field2])

      check = fn right -> 
        assertion_fails(
          FieldCalculator.merge_error(:b),
          [left: template, right: right],
          fn ->
            FieldCalculator.merge([b: template], [b: right])
          end)
      end

      check.(bad_func)
      check.(bad_args)
    end
  end

  test "subtracting field names" do
    original = Enum.map([:a, :b, :c], &({&1, "field calculator #{inspect &1}"}))

    original
    |> FieldCalculator.subtract([:b, :c, :d])
    |> assert_equal([a: "field calculator :a"])
  end

  test "which fields can be used in a calculation" do
    expect = fn changeset_fields, expected_ ->
      expected = MapSet.new(expected_)

      Sketch.valid_changeset(changeset_fields)
      |> FieldCalculator.valid_prerequisites
      |> assert_equal(expected)
    end

    [changes: %{field: 1}] |> expect.([:field])
    [changes: %{field: 1}, errors: [field: "..."]] |> expect.([])
  end

  test "which calculators can be used" do
    expect = fn [calc_args, valid_args], expected ->
      FieldCalculator.new(:irrelevant, calc_args)
      |> FieldCalculator.relevant?(MapSet.new(valid_args))
      |> assert_equal(expected)
    end
    
    [ [:field1], [           ] ] |> expect.(false)
    [ [:field1], [:field1    ] ] |> expect.(true)
    [ [:field1], [:field1, :x] ] |> expect.(true)

    [ [:field1, :field2], [:field2, :field1] ] |> expect.(true)
    [ [:field1, :field2], [         :field1] ] |> expect.(false)
    [ [:field1, :field2], [:field2         ] ] |> expect.(false)

    # non-name arguments don't matter
    [ [:field1, 5, :field2], [:field2, :field1] ] |> expect.(true)
  end

  test "creating checks based on a changeset" do
    expect = fn changeset_fields, expected ->
      f = &(&1 + &2 + &3)
      changeset = Sketch.valid_changeset(changeset_fields)
      [derived: FieldCalculator.new(f, [:field1, 5, :field2])]
      |> FieldCalculator.changeset_checks(changeset)
      |> assert_equal(expected)
    end

    [changes: %{field1: 1, field2: 2}] |> expect.(changes: [derived: 8])

    # A missing field means nothing checked
    [changes: %{field1: 1}] |> expect.([])
  end

  test "turning calculations into assertions" do
    input = [
      invalid: on_success(Date.from_iso8601!(:missing_field)), 
      dependent: on_success(Date.from_iso8601!(:datestring))
    ] |> IO.inspect

    a =
      input 
      |> FieldCalculator.assertions(Sketch.valid_changes(datestring: "2001-01-01"))
      |> singleton_content
      |> Tabular.nonflow_assertion_runners_for

    Sketch.valid_changes(dependent:   ~D[2001-01-01])
    |> a.pass.()

    Sketch.valid_changes(dependent: ~D[2111-11-11])
    |> a.fail.("Field `:dependent` has the wrong value")
    |> a.plus.(left: ~D[2111-11-11], right: ~D[2001-01-01])
#    |> a.plus.(expr: "slsl")

  end
  
end 
