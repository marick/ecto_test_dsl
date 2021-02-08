defmodule Run.Support.FormatParamsTest do
  use EctoTestDSL.Case
  alias T.Run.RunningExample

  @params %{
    age: 1,
    date: "2011-02-03",
    nested: %{a: 3},
    list: [1, 2, 3]
  }

  @interpreted_as_phoenix %{
    "age" => "1",
    "date" => "2011-02-03",
    "nested" => %{"a" => "3"},
    "list" => ["1", "2", "3"]}

  test "different formats" do
    expect = fn format, expected ->
      example = %{metadata: Enum.into(format, %{format: :raw})}
      running = RunningExample.from(example)

      RunningExample.formatted_params_for_history(running, @params)
      |> assert_fields(expected)
    end

    [format: :phoenix] |> expect.(@interpreted_as_phoenix)
    [format: :raw    ] |> expect.(@params)
    [                ] |> expect.(@params)
  end
end
