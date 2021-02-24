defmodule Run.Support.FormatParamsTest do
  use EctoTestDSL.Case
  alias T.Run.RunningExample

  # This is not intended to be a complee example, just shows
  # that the appropriate formatter is used.
  @params %{
    age: 1,
    date_string: "2011-02-03",
    date: ~D[2001-02-03],
    dates: [~D[2001-02-03]],
    complex: %{a: [~D[2001-02-03], %{a: [~D[2002-02-02]]}]}
  }

  @interpreted_as_phoenix %{
    "age" => "1",
    "date_string" => "2011-02-03",
    "date" => "2001-02-03",
    "dates" => ["2001-02-03"],
    "complex" => %{"a" => ["2001-02-03", %{"a" => ["2002-02-02"]}]}
  }

  test "different formats" do
    expect = fn format, expected ->
      example = %{metadata: Enum.into(format, %{format: :raw})}
      running = RunningExample.from(example)

      RunningExample.formatted_params(running, @params)
      |> assert_fields(expected)
    end

    [format: :phoenix] |> expect.(@interpreted_as_phoenix)
    [format: :raw    ] |> expect.(@params)
    [                ] |> expect.(@params)
  end
end
