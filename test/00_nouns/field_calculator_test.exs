defmodule Nouns.FieldCalculatorTest do
  use TransformerTestSupport.Drink.Me
  use T.Case
  alias T.Nouns.FieldCalculator

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
    |> assert_fields(calculation: inc, args: [:int_field])    
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
  end
  
end 
