defmodule Impl.BuildTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Build

  defstruct age: nil, name: nil

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


