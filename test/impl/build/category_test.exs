defmodule Api.CategoryTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Get

  defmodule Variant do
    # Note this tests what happens (no-op) when a hook function is missing.
  end

  defmodule Repeat do
    use TransformerTestSupport.Impl.Predefines
    
    def create_test_data() do
      start_with_variant(Variant, module_under_test: Anything)
      |> category(:valid, ok:    [params(a: 1,  b: 2)])
      |> category(:valid, other: [params(a: 11, b: 22)])
    end
  end

  test "categories are attached to examples" do
    assert Get.example(Repeat, :ok).category == :valid
  end

  test "you can repeat a category" do
    assert Repeat.Tester.params(:ok) ==    %{a: 1,  b: 2}
    assert Repeat.Tester.params(:other) == %{a: 11, b: 22}
  end
end  
