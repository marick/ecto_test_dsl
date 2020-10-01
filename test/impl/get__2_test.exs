defmodule Impl.GetTest__2 do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Get__2, as: Get
  alias TransformerTestSupport.Impl.Build__2, as: Build
  import FlowAssertions.AssertionA

  defstruct age: nil, date: nil

  describe "getting params" do
    test "without interpretation" do
      ok = %{params: %{age: 1, date: "2011-02-03"}}
      
      Build.start(__MODULE__, module_under_test: Whatever)
      Build.category(__MODULE__, :valid, %{ok: ok})

      assert Get.params(__MODULE__, :ok).age == 1
    end
  end

end 
