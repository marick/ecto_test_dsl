defmodule TransformerTestSupport.Case do
  defmacro __using__(_) do
    quote do 
      use TransformerTestSupport.Drink.Me
      use ExUnit.Case, async: true
      use FlowAssertions
      use FlowAssertions.Ecto
      use Given
      import FlowAssertions.AssertionA
      import FlowAssertions.Define.Tabular
      alias T.Run
    end
  end
end
