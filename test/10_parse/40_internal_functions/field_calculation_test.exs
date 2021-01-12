defmodule Parse.InternalFunctions.FieldCalculationTest do
  use TransformerTestSupport.Case
  use T.Predefines

  def function_in_module(x), do: x - 3

  test "on_success" do
    on_success(Date.diff(:date, ~D[2000-01-01]))
    |> assert_fields(calculation: &Date.diff/2,
                     args: [:date, ~D[2000-01-01]],
                     from: "on_success(Date.diff(:date, ~D[2000-01-01]))")
                          
    on_success(List.Chars.to_charlist(:date))
    |> assert_fields(calculation: &List.Chars.to_charlist/1,
                     args: [:date],
                     from: "on_success(List.Chars.to_charlist(:date))")
                          

    on_success(function_in_module(:date))
    |> assert_fields(calculation: &__MODULE__.function_in_module/1,
                     args: [:date],
                     from: "on_success(function_in_module(:date))")
    
    # The variant that accepts functions
    f = &(&1 + 1)
    on_success(f, applied_to: :date)
    |> assert_fields(calculation: f,
                     args: [:date],
                     from: "on_success(<fn>, applied_to: [:date])")
  end

  alias String.Chars

  test "on_success with aliases" do
    x = on_success(Chars.to_string(:date))
    x.calculation.(5)
    
    on_success(Chars.to_string(:date))
    |> assert_fields(calculation: &String.Chars.to_string/1,
                     args: [:date],
                     from: "on_success(Chars.to_string(:date))")
  end
  
end
