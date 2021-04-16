defmodule Nouns.FieldCalculatorTest do
  use EctoTestDSL.Case
  alias T.Nouns.FieldCalculator
  use T.Parse.Exports

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
    expect = TabularA.run_and_assert(
      &(ChangesetX.valid_changeset(&1) |> FieldCalculator.valid_prerequisites),
      &(assert_equal &1, MapSet.new(&2)))

    [changes: %{field: 1}] |> expect.([:field])
    [changes: %{field: 1}, errors: [field: "..."]] |> expect.([])
  end

  test "which calculators can be used" do
    expect = TabularA.run_and_assert(
      fn calc_args, valid_args ->
        FieldCalculator.new(:irrelevant, calc_args)
        |> FieldCalculator.relevant?(MapSet.new(valid_args))
      end)
    
    [ [:field1], [           ] ] |> expect.(false)
    [ [:field1], [:field1    ] ] |> expect.(true)
    [ [:field1], [:field1, :x] ] |> expect.(true)

    [ [:field1, :field2], [:field2, :field1] ] |> expect.(true)
    [ [:field1, :field2], [         :field1] ] |> expect.(false)
    [ [:field1, :field2], [:field2         ] ] |> expect.(false)

    # non-name arguments don't matter
    [ [:field1, 5, :field2], [:field2, :field1] ] |> expect.(true)
  end

  describe "FieldCalculator.assertions" do 
    test "turning calculations into assertions" do
      input = [
        dependency_missing: on_success(Date.from_iso8601!(:missing_field)), 
        dependency_present: on_success(Date.from_iso8601!(:datestring))
      ]
  
      [missing, present] =
        input 
        |> FieldCalculator.assertions(ChangesetX.valid_changes(datestring: "2001-01-01"))
        |> Enum.map(&nonflow_assertion_runners_for/1)
  
      # dependency_missing
      ChangesetX.valid_changes(some_other_field: "irrelevant")
      |> missing.pass.()
      
      ChangesetX.valid_changes(some_other_field: "irrelevant", dependency_missing: 5)
      |> missing.fail.("Field `:dependency_missing` should not have changed, but it did")
      |> missing.plus.(expr: "on_success(Date.from_iso8601!(:missing_field))")
      
      # dependency_present
      ChangesetX.valid_changes(dependency_present: ~D[2001-01-01])
      |> present.pass.()
  
      ChangesetX.valid_changes(dependency_present: ~D[2111-11-11])
      |> present.fail.("Field `:dependency_present` has the wrong value")
      |> present.plus.(left: ~D[2111-11-11], right: ~D[2001-01-01])
      |> present.plus.(expr: "on_success(Date.from_iso8601!(:datestring))")
  
  
      ChangesetX.valid_changes(calculated_field: :is_missing_in_changeset)
      |> present.fail.("Field `:dependency_present` is missing")
      |> present.plus.(left: %{calculated_field: :is_missing_in_changeset},
                       right: [dependency_present: ~D[2001-01-01]])
    end
  end  
end 
