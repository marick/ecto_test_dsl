defmodule Impl.GetTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Get
  alias TransformerTestSupport.Impl.Build
#  import FlowAssertions.AssertionA

  defstruct age: nil, date: nil

  describe "getting params" do
    test "without interpretation" do
      ok = %{params: %{age: 1, date: "2011-02-03"}}
      
      Build.start(__MODULE__)
      Build.category(__MODULE__, :valid, %{ok: ok})

      Get.get_params(__MODULE__, :ok)
      |> assert_fields(ok.params)
    end

    test "phoenix format" do
      ok = %{params: %{age: 1,
                       date: "2011-02-03",
                       nested: %{a: 3},
                       list: [1, 2, 3]}}
      
      Build.start(__MODULE__, format: :phoenix)
      Build.category(__MODULE__, :valid, %{ok: ok})

      Get.get_params(__MODULE__, :ok)
      |> assert_fields(%{
            "age" => "1",
            "date" => "2011-02-03",
            "nested" => %{"a" => "3"},
            "list" => ["1", "2", "3"]})
    end
    
    test "raw format" do
      raw = %{age: 1,
              date: "2011-02-03",
              nested: %{a: 3},
              list: [1, 2, 3]}
      ok = %{params: raw}
      
      Build.start(__MODULE__, format: :raw)
      Build.category(__MODULE__, :valid, %{ok: ok})

      Get.get_params(__MODULE__, :ok)
      |> assert_fields(raw)
    end
  end
end 
