defmodule Impl.TestDataServerTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.TestDataServer

  
  defmodule Examples do
    def create_test_data() do
      %{examples: [one: %{params: %{a: 1}}],
        other_stuff: "other stuff"}
    end
  end

  test "lazy initialization" do
    assert TestDataServer.test_data(Examples) == Examples.create_test_data()    
    assert TestDataServer.test_data(Examples) == Examples.create_test_data()    
  end
end
