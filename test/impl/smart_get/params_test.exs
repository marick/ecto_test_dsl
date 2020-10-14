defmodule Impl.SmartGet.ParamsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.{SmartGet,TestDataServer}
  import TransformerTestSupport.Impl.Build

  # This avoids the rigamarole of having to set up a variant for callbacks.
  def stash(f),
    do: f.() |> TestDataServer.put_value_into(__MODULE__)

  @ok %{params: %{age: 1,
                  date: "2011-02-03",
                  nested: %{a: 3},
                  list: [1, 2, 3]}}

  def with_format(start_args) do 
    stash(fn -> 
      start(start_args)
      |> category(:valid, [ok: @ok])
    end)
  end

  describe "getting params" do
    test "phoenix format" do
      with_format(format: :phoenix)   

      SmartGet.params(__MODULE__, :ok)
      |> assert_fields(%{
            "age" => "1",
            "date" => "2011-02-03",
            "nested" => %{"a" => "3"},
            "list" => ["1", "2", "3"]})
    end
    
    test "explicit raw format" do
      with_format(format: :raw)

      SmartGet.params(__MODULE__, :ok)
      |> assert_fields(@ok.params)
    end

    test "default format is raw" do
      with_format([])

      SmartGet.params(__MODULE__, :ok)
      |> assert_fields(@ok.params)
    end

    test "can smart-get from either a test data name or value" do
      with_format([])

      from_name = __MODULE__ |> SmartGet.params(:ok)
      from_value = TestDataServer.test_data(__MODULE__) |> SmartGet.params(:ok)
      assert from_name == from_value
    end
  end
end 
