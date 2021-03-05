defmodule Parse.BuildStateTest do
  use EctoTestDSL.Case
  alias T.Parse.BuildState

  test "add_example adds an example" do
    BuildState.put(%{examples: [name1: "value1"]})

    BuildState.add_example({:name2, "value2"})

    assert BuildState.current == %{examples: [name1: "value1", name2: "value2"]}
  end
end  
