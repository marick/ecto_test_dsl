defmodule EnumXTest do
  use ExUnit.Case

  describe "take_until" do
    test "doesn't stop" do
      assert [1, 2, 3] == EnumX.take_until([1, 2, 3], fn _ -> false end)
    end

    test "does stop" do
      assert [1, 2] == EnumX.take_until([1, 2, 3], &(&1 == 2))
    end
  end
end
