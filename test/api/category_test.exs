defmodule Api.CategoryTest do
  use TransformerTestSupport.Case
  use TransformerTestSupport.Impl.Predefines

  defmodule Variant do
    def adjust_top_level(test_data), do: test_data
  end

  @minimal_start [module_under_test: Anything, variant: Variant]

  setup_all do
    start(@minimal_start)
  end

  test "you can repeat a category" do 
    category(:valid, ok:    [params(a: 1,  b: 2)])
    category(:valid, other: [params(a: 11, b: 22)])

    assert Tester.params(:ok) ==    %{a: 1,  b: 2}
    assert Tester.params(:other) == %{a: 11, b: 22}
  end
end  
