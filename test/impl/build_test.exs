defmodule Impl.BuildTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl
  alias TransformerTestSupport.Impl.Build
  use TransformerTestSupport.Impl.Predefines

  defmodule Variant do
    def run_start_hook(test_data),
      do: Map.put(test_data, :adjusted, true)
  end

  @minimal_start [module_under_test: Anything, variant: Variant]

  test "minimal start" do
    expected = 
      %{format: :raw,
        module_under_test: Anything,
        variant: Variant,
        examples: [],
        adjusted: true
       }
    
    assert Build.start(@minimal_start) == expected
  end

  test "params_like" do
    previous = [ok: %{params:                   %{a: 1, b: 2 }}]
    f = Build.make__params_like(:ok, except:           [b: 22, c: 3])
    expected =      %{params:                   %{a: 1, b: 22, c: 3}}

    assert Impl.Like.expand(%{params: f}, :example, previous) == expected
  end


  test "category" do
    %{examples: [new: new, ok: ok]} =
      Build.start(@minimal_start)
      |> Build.category(:valid,
           ok: [params(age: 1)],
           new: [params_like(:ok, except: [age: 2])])

      assert ok.params == %{age: 1}
      assert new.params == %{age: 2}
  end
end
