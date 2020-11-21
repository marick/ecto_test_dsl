defmodule Build.WorkflowTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet

  defmodule Repeat do
    use TransformerTestSupport.Variants.Trivial
    
    def create_test_data() do
      start_with_variant(Trivial, module_under_test: Anything)
      |> workflow(:valid, ok:    [params(a: 1,  b: 2)])
      |> workflow(:valid, other: [params(a: 11, b: 22)])
    end
  end

  test "workflows are attached to examples" do
    assert SmartGet.Example.get(Repeat, :ok).metadata.workflow_name == :valid
  end

  test "you can repeat a workflow" do
    assert Repeat.Tester.params(:ok) ==    %{a: 1,  b: 2}
    assert Repeat.Tester.params(:other) == %{a: 11, b: 22}
  end
end  
