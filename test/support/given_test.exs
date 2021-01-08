defmodule GivenTest do
  use ExUnit.Case
  import Mockery.Macro
  use Given

  describe "decomposing a function call" do 
    test "with module" do
      input = quote do: Process.add(:key, "value")
      actual = Given.Util.decompose_call(input, __MODULE__)
      expected = {Process, [add: 2], [:key, "value"]}
      assert actual == expected
    end

    test "without module" do
      input = quote do: to_string(5)
      actual = Given.Util.decompose_call(input, __MODULE__)
      expected = {__MODULE__, [to_string: 1], [5]}
      assert actual == expected
    end
  end

  def function_under_test(count) do
    {:ok, mockable(Date).add(~D[2001-02-03], count)}
  end

  test "given" do
    # Manifest constants
    given Date.add(~D[2001-02-03], 3), return: "return for 3"

    # Calculations and variables
    date = ~D[2001-02-03]
    given(Date.add(date, 1+3), return: "return for 4")

    assert function_under_test(3) == {:ok, "return for 3"}
    assert function_under_test(4) == {:ok, "return for 4"}
    assert function_under_test(5) == {:ok, nil}
  end
end
