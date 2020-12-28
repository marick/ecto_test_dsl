defmodule Build.WorkflowTest do
  use TransformerTestSupport.Drink.Me
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet

  defmodule Examples do
    use Template.EctoClassic.Insert
    
    def create_test_data() do
      started()
      |> workflow(:success, ok:    [params(a: 1,  b: 2)])
         # Note repeated name
      |> workflow(:success, other: [params(a: 11, b: 22)])
    end
  end

  test "workflows are attached to examples" do
    SmartGet.Example.get(Examples, :ok)
    |> SmartGet.Example.workflow_name
    |> assert_equal(:success)
  end

  
  test "workflow examples accumulate" do
    assert Examples.Tester.params(:ok) ==    %{"a" => "1",  "b" => "2"}
    assert Examples.Tester.params(:other) == %{"a" => "11", "b" => "22"}
  end
end  
