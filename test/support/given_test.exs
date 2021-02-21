defmodule GivenTest do
  use ExUnit.Case
  import Mockery.Macro
  use Given
  alias Given.Util
  import FlowAssertions.AssertionA, only: [assertion_fails: 2]

  def function_under_test_uses_date(count) do
    {:ok, mockable(Date).add(~D[2001-02-03], count)}
  end

  describe "matching" do
    test "matching constants" do
      # Manifest constants
      given Date.add(~D[2001-02-03], 3), return: "return for 3"
      
      # Calculations and variables
      date = ~D[2001-02-03]
      given(Date.add(date, 1+3), return: "return for 4")
      
      assert function_under_test_uses_date(3) == {:ok, "return for 3"}
      assert function_under_test_uses_date(4) == {:ok, "return for 4"}
    end

    test "an exact argument match replaces the previous value" do
      given Date.add(~D[2001-02-03], 3), return: "replaced"
      given Date.add(~D[2001-02-03], 3), return: "used"
      
      assert function_under_test_uses_date(3) == {:ok, "used"}
    end

    test "a completely missed function falls through" do
      # because no mock is set up
      assert {:ok, ~D[2001-02-08]} = function_under_test_uses_date(5)
    end

    test "a call without a matching arglist produces an error" do
      given Date.add(~D[2001-02-03], 3), return: "not used"

      assertion_fails("You did not set up a stub for Date.add(~D[2001-02-03], 5)",
        fn -> 
          function_under_test_uses_date(5)
        end)
    end
    
    test "matching with don't cares" do
      given Date.add(~D[2001-02-03], @any), return: "return value"
      
      assert function_under_test_uses_date(3) == {:ok, "return value"}
    end

    test "earliest match is selected" do
      given Date.add(~D[2001-02-03], @any), return: "return value"
      given Date.add(~D[2001-02-03], :specific), return: "impossible"

      assert function_under_test_uses_date(:specific) == {:ok, "return value"}
    end
    
    test "... so an @any can be used as a fallback" do
      given Date.add(~D[2001-02-03], :specific), return: "specific"
      given Date.add(~D[2001-02-03], @any), return: "return value"

      assert function_under_test_uses_date(:specific) == {:ok, "specific"}
      assert function_under_test_uses_date(:other) == {:ok, "return value"}
    end

    def calls_with_default(map, key, default),
      do: mockable(Map).get(map, key, default)
    def calls_without_default(map, key), 
      do: mockable(Map).get(map, key)

    test "the `given` arglist determines the arity" do
      given Map.get(%{}, :key, :default), return: 3
      given Map.get(%{}, :key, @any),     return: "3 default"
      given Map.get(%{}, :key),           return: 2

      assert calls_with_default(%{}, :key, :default) == 3
      assert calls_with_default(%{}, :key, :other) == "3 default"

      assert calls_without_default(%{}, :key) == 2
    end

  end
    
  describe "varieties of module descriptions" do 

    def function_under_test_uses_string_dot_chars(arg) do
      {:ok, mockable(String.Chars).to_string(arg)}
    end
    
    alias String.Chars
    def function_under_test_uses_chars(arg) do
      {:ok, mockable(Chars).to_string(arg)}
    end
    
    test "given with a compound non-aliased module" do
      given String.Chars.to_string(3), return: "return for 3 S.C"
      
      assert function_under_test_uses_string_dot_chars(3) == {:ok, "return for 3 S.C"}
    end
    
    test "given with an aliased module" do
      given Chars.to_string(3), return: "return for 3 C"
      
      assert function_under_test_uses_string_dot_chars(3) == {:ok, "return for 3 C"}
    end
    
    test "aliased and unaliased versions resolve to the same module" do
      given String.Chars.to_string(3), return: "return for 3 S.C"
      assert function_under_test_uses_chars(3) == {:ok, "return for 3 S.C"}
      assert function_under_test_uses_string_dot_chars(3) == {:ok, "return for 3 S.C"}
    end
    
  end

  describe "util" do 
    test "matchers" do
      assert Util.make_matcher([1, 2]).([1, 2   ])
      refute Util.make_matcher([1, 2]).([1, 2222])
      assert Util.make_matcher([1, 1+1]).([1, 2])
      assert Util.make_matcher([1, @any]).([1, 3333])
    end
  end    
end
