defmodule TransformerTestSupport.Case do
  defmacro __using__(_) do
    quote do 
      use TransformerTestSupport.Drink.Me
      use ExUnit.Case, async: true
      use FlowAssertions
      use FlowAssertions.Ecto
      import FlowAssertions.AssertionA
      import FlowAssertions.Define.Tabular      
    end
  end
end
