defmodule Impl.SmartGet.ExampleTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.{SmartGet,TestDataServer}
  import TransformerTestSupport.Impl.Build

  # This makes this a test of test of how `SmartGet` generates
  # two variant functions, but without the rigamarole of a whole
  # Variant.
  def stash(f),
    do: f.() |> TestDataServer.put_value_into(__MODULE__)

  setup do
    ok = %{category: :success}
    stash(fn -> 
      start()
      |> category(:success, [ok: ok])
    end)
    :ok
  end    

  describe "getting an example" do
    test "via module name" do
      SmartGet.example(__MODULE__, :ok)
      |> assert_field(category: :success)
    end

    test "via module data" do
      SmartGet.test_data(__MODULE__)
      |> SmartGet.example(:ok)
      |> assert_field(category: :success)
    end
  end
end 
