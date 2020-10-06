defmodule Impl.AgentTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.Agent

  
  defmodule Params do
    def create_test_data() do
      start()
    end

    def start(), do: %{examples: [one: %{params: %{a: 1}}]}

  end

  setup do
    Agent.start_test_data(__MODULE__, Params.create_test_data())
  end

  test "add_test_data" do
    assert Agent.test_data(__MODULE__) == Params.start
  end

  describe "deep_merge" do
    test "no change" do
      Agent.deep_merge(__MODULE__, Params.start)
      assert Agent.test_data(__MODULE__) == Params.start
    end

    test "a new example is added to the end example" do
      Agent.deep_merge(__MODULE__, %{examples: [two: "...stuff..."]})
      assert %{
        examples: [one: _, two: "...stuff..."]
      } = Agent.test_data(__MODULE__)
    end
  end
end
