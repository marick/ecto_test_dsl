defmodule SmartGet.ExampleTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet.Example
  alias TransformerTestSupport.TestDataServer


  defmodule Examples do 
    use Template.Trivial

    def create_test_data do
      started() |> 
      workflow(     :any_workflow,
        example: [params(a: 1)])
    end
  end

  test "getting an example can use either module name or data" do
    from_module_name =
      Example.get(Examples, :example)
    from_test_data =
      TestDataServer.test_data(Examples).examples
      |> Keyword.get(:example)

    assert from_module_name == from_test_data
    assert from_module_name.params == %{a: 1}
  end
end 
