defmodule TestDataServerTest do
  use EctoTestDSL.Case
  alias EctoTestDSL.TestDataServer

  
  defmodule Examples do
    def create_test_data() do
      %{examples: [one: %{params: %{a: 1}}],
        other_stuff: "other stuff"}
    end
  end

  test "lazy initialization" do
    TestDataServer.test_data(Examples)
    |> assert_field(other_stuff: "other stuff")

    # Idempotent
    TestDataServer.test_data(Examples)
    |> assert_field(other_stuff: "other stuff")
  end
end
