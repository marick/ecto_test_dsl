defmodule GivenTest do
  use ExUnit.Case
  import Mockery.Macro
  use Given

  describe "decomposing a function call" do
    defp expect(input, expected) do
      actual = Given.Util.decompose_call(input, __MODULE__)
      assert actual == expected
    end
    
    test "straightforward cases" do
      # without module
      (quote do:               to_string(      5))
      |> expect({__MODULE__, [to_string: 1], [5]})

      # Single module
      (quote do:  Process.add(        :key, "value"))
      |> expect({Process, [add: 2], [:key, "value"]})

      # Nested module
      (quote do: String.Chars.to_string(4))
      |> expect({String.Chars, [to_string: 1], [4]})
    end

    test "aliased module requires later work" do
      alias String.Chars

      # Note that it expands to the top-level Elixir.Chars because
      # `decompose_call` doesn't have access to the alias information
      # in `__ENV__`.
      (quote do: Chars.to_string(        4))
      |> expect({Elixir.Chars, [to_string: 1], [4]})
    end
    
  end

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
