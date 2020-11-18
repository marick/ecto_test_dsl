defmodule RunningExample.TraceServerTest do
  use ExUnit.Case, async: false
  alias TransformerTestSupport, as: T
  alias T.RunningExample.TraceServer

  test "indentation leaders" do
    pass = fn arg, expected -> 
      TraceServer.nested(fn ->
        actual = TraceServer.indent(arg) |> IO.iodata_to_binary
        assert actual == expected
      end)
    end

    "hi"   |> pass.("  hi")
    ["hi"] |> pass.("  hi")

    "hi\nbye" |> pass.("  hi\n  bye")
  end
end
