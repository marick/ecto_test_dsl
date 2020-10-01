defmodule Impl.GetTest__2 do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Get__2, as: Get
  alias TransformerTestSupport.Impl.Build__2, as: Build
#  import FlowAssertions.AssertionA

  defstruct age: nil, date: nil

  describe "getting params" do
    test "without interpretation" do
      ok = %{params: %{age: 1, date: "2011-02-03"}}
      
      Build.start(__MODULE__)
      Build.category(__MODULE__, :valid, %{ok: ok})

      Get.params(__MODULE__, :ok)
      |> assert_fields(ok.params)
    end

    test "phoenix format" do
      ok = %{params: %{age: 1, date: "2011-02-03"}}
      
      Build.start(__MODULE__, format: :phoenix)
      Build.category(__MODULE__, :valid, %{ok: ok})

      Get.params(__MODULE__, :ok)
      |> assert_fields(%{"age" => "1", "date" => "2011-02-03"})
    end
  end
end 
