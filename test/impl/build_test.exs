defmodule Impl.BuildTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl

  defmodule Variant do
    def adjust_top_level(test_data),
      do: Map.put(test_data, :adjusted, true)
  end

  @minimal_start [module_under_test: Anything, variant: Variant]

  test "minimal start" do
    register_under = __MODULE__
    
    Impl.Build.start(register_under, @minimal_start)
    expected = 
      %{format: :raw,
        module_under_test: Anything,
        variant: Variant,
        adjusted: true
       }

    assert Impl.Agent.get(register_under) == expected
  end
end
