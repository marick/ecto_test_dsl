defmodule Impl.SmartGet.ParamsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.SmartGet
  import TransformerTestSupport.Impl.Build

  @ok %{params: %{age: 1,
                  date: "2011-02-03",
                  nested: %{a: 3},
                  list: [1, 2, 3]}}

  @phoenix_params %{
    "age" => "1",
    "date" => "2011-02-03",
    "nested" => %{"a" => "3"},
    "list" => ["1", "2", "3"]}

  def with_format(start_args) do
    start(start_args)
    |> category(:valid, [ok: @ok])
    |> propagate_metadata
  end

  describe "getting params" do
    test "phoenix format" do
      with_format(format: :phoenix)   
      |> SmartGet.Params.get(:ok)
      |> assert_fields(@phoenix_params)
    end
    
    test "explicit raw format" do
      with_format(format: :raw)
      |> SmartGet.Params.get(:ok)
      |> assert_fields(@ok.params)
    end

    test "default format is raw" do
      with_format([])
      |> SmartGet.Params.get(:ok)
      |> assert_fields(@ok.params)
    end

    test "via an example" do
      with_format(format: :phoenix)
      |> SmartGet.Example.get(:ok)
      |> SmartGet.Example.params
      |> assert_fields(@phoenix_params)
    end
  end
end 
