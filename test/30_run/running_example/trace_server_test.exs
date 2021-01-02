defmodule RunningExample.Run.TraceServerTest do
  use TransformerTestSupport.Drink.Me
  use ExUnit.Case, async: false
  alias T.Run.RunningExample.TraceServer

  test "indentation leaders" do
    pass = fn arg, expected -> 
      TraceServer.nested(fn ->
        actual = TraceServer.indented(arg) |> IO.iodata_to_binary
        assert actual == expected
      end)
    end

    "hi"   |> pass.("  hi")
    ["hi"] |> pass.("  hi")

    "hi\nbye" |> pass.("  hi\n  bye")
  end
end
