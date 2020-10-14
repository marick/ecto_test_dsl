defmodule Impl.SmartGet.ParamsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.SmartGet
  import TransformerTestSupport.Impl.Build

  @ok %{params: %{age: 1,
                  date: "2011-02-03",
                  nested: %{a: 3},
                  list: [1, 2, 3]}}

  def with_format(start_args) do
    start(start_args)
    |> category(:valid, [ok: @ok])
  end

  describe "getting params" do
    test "phoenix format" do
      with_format(format: :phoenix)   
      |> SmartGet.params(:ok)
      |> assert_fields(%{
            "age" => "1",
            "date" => "2011-02-03",
            "nested" => %{"a" => "3"},
            "list" => ["1", "2", "3"]})
    end
    
    test "explicit raw format" do
      with_format(format: :raw)
      |> SmartGet.params(:ok)
      |> assert_fields(@ok.params)
    end

    test "default format is raw" do
      with_format([])
      |> SmartGet.params(:ok)
      |> assert_fields(@ok.params)
    end
  end
end 
