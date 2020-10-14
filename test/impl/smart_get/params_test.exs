defmodule Impl.SmartGet.ParamsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.{SmartGet,TestDataServer}
  import TransformerTestSupport.Impl.Build

  # This avoids the rigamarole of having to set up a variant for callbacks.
  def stash(f),
    do: f.() |> TestDataServer.put_value_into(__MODULE__)

  describe "getting params" do
    test "phoenix format" do
      ok = %{params: %{age: 1,
                       date: "2011-02-03",
                       nested: %{a: 3},
                       list: [1, 2, 3]}}

      stash(fn -> 
        start(format: :phoenix)
        |> category(:valid, [ok: ok])
      end)

      SmartGet.params(__MODULE__, :ok)
      |> assert_fields(%{
            "age" => "1",
            "date" => "2011-02-03",
            "nested" => %{"a" => "3"},
            "list" => ["1", "2", "3"]})
    end
    
    test "explicit raw format" do
      raw = %{age: 1,
              date: "2011-02-03",
              nested: %{a: 3},
              list: [1, 2, 3]}
      ok = %{params: raw}

      stash(fn -> 
        start(format: :raw)
        |> category(:valid, [ok: ok])
      end)

      SmartGet.params(__MODULE__, :ok)
      |> assert_fields(raw)
    end

    test "default format is raw" do
      ok = %{params: %{age: 1, date: "2011-02-03"}}
      
      stash(fn ->
        start()
        |> category(:valid, [ok: ok])
      end)

      SmartGet.params(__MODULE__, :ok)
      |> assert_fields(ok.params)
    end

    test "can smart-get from either a test data name or value" do
      ok = %{params: %{age: 1, date: "2011-02-03"}}
      
      stash(fn ->
        start()
        |> category(:valid, [ok: ok])
      end)

      from_name = __MODULE__ |> SmartGet.params(:ok)
      from_value = TestDataServer.test_data(__MODULE__) |> SmartGet.params(:ok)
      assert from_name == from_value
    end
  end
end 
