defmodule Api.LikeTest do
  use TransformerTestSupport.Case
  use TransformerTestSupport.Impl.Predefines

  defmodule Variant do
    def adjust_top_level(test_data),
      do: Map.put(test_data, :adjusted, true)
  end

  @minimal_start [module_under_test: Anything, variant: Variant]

  setup_all do
    start(@minimal_start)
  end

  test "like" do 
    category(:valid, ok: [                    params(a: 1, b: 2)])
    category(:invalid, similar: [params_like(:ok, except: [b: 4])])

    assert example(:similar).params ==             %{a: 1, b: 4}
  end

  test "using like to refer to values within the same category" do
    category(:valid, [
          ok: [params: %{a: 1, b: 2}],
          similar: [params_like(:ok, except: [b: 4])]
        ])

    assert example(:similar).params == %{a: 1, b: 4}
  end

  test "multiple categories" do
    category(:valid, [
          ok: [params: %{a: 1, b: 2}],
          similar: [params_like(:ok, except: [b: 4])]
        ])
    category(:invalid, [
          different: [params_like(:ok, except: [c: 383])]
        ])

    assert example(:ok).params ==        %{a: 1, b: 2}
    assert example(:similar).params ==   %{a: 1, b: 4}
    assert example(:different).params == %{a: 1, b: 2, c: 383}
  end

  test "like can copy everything" do 
    category(:valid, ok: [params(a: 1, b: 2)])
    category(:invalid, similar: [params_like(:ok)])

    assert example(:similar).params == example(:similar).params
  end
end  
