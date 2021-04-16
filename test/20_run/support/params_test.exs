defmodule Run.Support.ParamsTest do
  use EctoTestDSL.Case
  alias T.Run.Params

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
    expect = TabularA.run_and_assert(
      &(Params.format(@params, &1)),
      &assert_fields/2)

    :phoenix |> expect.(@interpreted_as_phoenix)
    :raw     |> expect.(@params)

    assertion_fails(~r/`nil` is not a valid format for test data params/,
      [message: ~r/Try one of these: `\[:phoenix, :raw\]`/],
      fn -> 
        Params.format(@params, nil)
      end)
  end
end
