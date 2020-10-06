defmodule Impl.BuildTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl
  alias TransformerTestSupport.Impl.Build

  defmodule Variant do
    def adjust_top_level(test_data),
      do: Map.put(test_data, :adjusted, true)
  end

  @minimal_start [module_under_test: Anything, variant: Variant]

  test "minimal start" do
    register_under = __MODULE__
    
    Build.start(register_under, @minimal_start)
    expected = 
      %{format: :raw,
        module_under_test: Anything,
        variant: Variant,
        examples: [],
        adjusted: true
       }

    assert Impl.Agent.test_data(register_under) == expected
  end

  test "params_like" do
    previous = [ok: %{params:                   %{a: 1, b: 2 }}]
    f = Build.params_like_function(:ok, except:        [b: 22, c: 3])
    expected =      %{params:                   %{a: 1, b: 22, c: 3}}

    assert Impl.Like.expand(%{params: f}, :example, previous) == expected
  end
    
end
