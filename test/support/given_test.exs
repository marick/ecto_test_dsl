defmodule GivenTest do
  use ExUnit.Case
  import Mockery.Macro
  use Given

  def function_under_test_uses_date(count) do
    {:ok, mockable(Date).add(~D[2001-02-03], count)}
  end

  test "given with a simple non-aliased module" do
    # Manifest constants
    given Date.add(~D[2001-02-03], 3), return: "return for 3"

    # Calculations and variables
    date = ~D[2001-02-03]
    given(Date.add(date, 1+3), return: "return for 4")

    assert function_under_test_uses_date(3) == {:ok, "return for 3"}
    assert function_under_test_uses_date(4) == {:ok, "return for 4"}
  end

  def function_under_test_uses_string_dot_chars(arg) do
    {:ok, mockable(String.Chars).to_string(arg)}
  end

  test "given with a compound non-aliased module" do
    given String.Chars.to_string(3), return: "return for 3 S.C"

    assert function_under_test_uses_string_dot_chars(3) == {:ok, "return for 3 S.C"}
  end

  alias String.Chars
  def function_under_test_uses_chars(arg) do
    {:ok, mockable(Chars).to_string(arg)}
  end

  test "given with an aliased module" do
    given Chars.to_string(3), return: "return for 3 C"

    assert function_under_test_uses_string_dot_chars(3) == {:ok, "return for 3 C"}
  end

  test "aliased and unaliased versions resolve to the same module" do
    given String.Chars.to_string(3), return: "return for 3 S.C"
    assert function_under_test_uses_chars(3) == {:ok, "return for 3 S.C"}

    given Chars.to_string(3), return: "return for 3 C"
    assert function_under_test_uses_string_dot_chars(3) == {:ok, "return for 3 C"}
  end

  test "a missing value flunks the test" do
    # Note that the flunking only happens if the function has been stubbed.
    assert {:ok, _date} = function_under_test_uses_date(5)

    given Date.add(~D[2001-02-03], 3), return: "return for 3"

    error =
      assert_raise(ExUnit.AssertionError,
        fn ->
          function_under_test_uses_date(5)
        end)
    assert String.contains?(error.message,
      "You did not set up a stub for Date.add(~D[2001-02-03], 5)")
  end
end
