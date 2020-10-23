defmodule SmartGet.ParamsTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.SmartGet

  @ok %{params: %{age: 1,
                  date: "2011-02-03",
                  nested: %{a: 3},
                  list: [1, 2, 3]}}

  @phoenix_params %{
    "age" => "1",
    "date" => "2011-02-03",
    "nested" => %{"a" => "3"},
    "list" => ["1", "2", "3"]}

  def with_format(start_args),
    do: TestBuild.one_category(start_args, [ok: @ok])

  test "different formats" do
    expect = fn format, expected ->
      with_format(format)
      |> SmartGet.Params.get(:ok)
      |> assert_fields(expected)
    end

    [format: :phoenix] |> expect.(@phoenix_params)
    [format: :raw    ] |> expect.(@ok.params)
    [                ] |> expect.(@ok.params)
  end
    
  test "different routes to params" do
    test_data = with_format(format: :phoenix)

    via_test_data =  test_data |> SmartGet.Params. get(:ok)
    via_example =    test_data |> SmartGet.Example.get(:ok) |> SmartGet.Params.get

    assert via_test_data == via_example
  end
end 
