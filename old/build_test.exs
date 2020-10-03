defmodule Impl.BuildTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Build

  defstruct age: nil, name: nil

  describe "to_strings" do
    test "empty" do
      assert Build.to_strings(%{}) == %{}
    end

    test "keys" do
      input = %{a: "a", b: "b"}
      expected = %{"a" => "a", "b" => "b"}
      assert Build.to_strings(input) == expected
    end

    test "integer values are turned to strings" do
      input = %{a: 1, b: 2}
      expected = %{"a" => "1", "b" => "2"}
      assert Build.to_strings(input) == expected
    end

    test "nested maps are descended" do
      input = %{a: 1, b: %{bb: 2}}
      expected = %{"a" => "1", "b" => %{"bb" => "2"}}

      assert Build.to_strings(input) == expected
    end

    test "array values are turned into arrays of strings" do
      input = %{a: 1, b: [1, 2]}
      expected = %{"a" => "1", "b" => ["1", "2"]}
      assert Build.to_strings(input) == expected
    end

    test "it's OK to pass a keyword list as the top level" do
      input = [a: 1, b: [1, 2]]
      expected = %{"a" => "1", "b" => ["1", "2"]}
      assert Build.to_strings(input) == expected
    end
  end


  describe "adding real examples" do
    setup do 
      example = %{params: Build.to_strings(%{a: 1, name: "first"})}
      examples = Build.add_real_example({:first, example}, %{})
      assert %{first: example} == examples
      [start: examples]
    end

    test "like allows replacement", %{start: start}  do
      example = %{params: Build.like(:first, except: [name: "different"])}
            
      %{second: %{params: params}} =
        Build.add_real_example({:second, example}, start)

      assert %{"a" => "1", "name" => "different"} == params
    end

    test "like can completely duplicate params", %{start: start}  do
      example = %{params: Build.like(:first)}
      actual = Build.add_real_example({:second, example}, start)

      assert actual.first.params == actual.second.params
    end
  end
end


