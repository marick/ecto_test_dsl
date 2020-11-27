defmodule Build.WorkflowTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet

  defmodule Examples do
    use Template.Trivial
    
    def create_test_data() do
      started()
      |> workflow(:valid, ok:    [params(a: 1,  b: 2)])
         # Note repeated name
      |> workflow(:valid, other: [params(a: 11, b: 22)])
    end
  end

  test "workflows are attached to examples" do
    SmartGet.Example.get(Examples, :ok)
    |> SmartGet.Example.workflow_name
    |> assert_equal(:valid)
  end

  test "workflow examples accumulate" do
    assert Examples.Tester.params(:ok) ==    %{a: 1,  b: 2}
    assert Examples.Tester.params(:other) == %{a: 11, b: 22}
  end
end  
