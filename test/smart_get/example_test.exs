defmodule SmartGet.ExampleTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet.Example
  alias TransformerTestSupport.TestDataServer

  @params [a: 1]
  @expected %{a: 1}

  setup do
    TestBuild.with_params(:ok, @params) |> TestBuild.stash(__MODULE__)
    :ok
  end    

  @tag :skip # current
  test "getting an example can use either module name or data" do
    finds_example = &(Example.get(&1, :ok) |> assert_field(params: @expected))

                             __MODULE__  |> finds_example.()
    TestDataServer.test_data(__MODULE__) |> finds_example.()
  end

  @tag :skip # current
  test "pieces" do
    example = Example.get(__MODULE__, :ok)
    
    assert Example.params(example) == @expected
  end
end 
