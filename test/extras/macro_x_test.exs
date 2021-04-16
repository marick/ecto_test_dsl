defmodule MacroXTest do
  use ExUnit.Case
  alias EctoTestDSL.MacroX
  alias FlowAssertions.TabularA

  describe "decomposing a function call" do
    defp expect(input, expected) do
      actual = MacroX.decompose_call_alt(input)
      assert actual == expected
    end
    
    test "straightforward cases" do
      # without module
      (quote do:               to_string(      5))
      |> expect({:in_calling_module, :use__MODULE__, [to_string: 1], [5]})

      # Single module
      (quote do:  Process.add(        :key, "value"))
      |> expect({:in_named_module, Process, [add: 2], [:key, "value"]})

      # Nested module
      (quote do: String.Chars.to_string(4))
      |> expect({:in_named_module, String.Chars, [to_string: 1], [4]})
    end

    test "aliased module requires later work" do
      alias String.Chars

      # Note that it expands to the top-level Elixir.Chars because
      # `decompose_call` doesn't have access to the alias information
      # in `__ENV__`.
      (quote do: Chars.to_string(        4))
      |> expect({:in_named_module, Elixir.Chars, [to_string: 1], [4]})
    end
    
  end

  test "alias_to_module" do
    expect = TabularA.run_and_assert(
      &(MacroX.alias_to_module(&1, %{aliases: &2})))

    [Chars, [{Chars, String.Chars}]] |> expect.(String.Chars)
    [Chars, [                     ]] |> expect.(       Chars)
  end
end
