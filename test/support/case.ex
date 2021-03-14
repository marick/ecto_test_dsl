defmodule EctoTestDSL.Case do
  defmacro __using__(_) do
    quote do 
      use EctoTestDSL.Drink.Me
      use ExUnit.Case, async: true
      use FlowAssertions
      use FlowAssertions.Ecto
      use MockeryExtras.Given
      import FlowAssertions.AssertionA
      import FlowAssertions.Define.Tabular
      alias T.Run
      import ShorterMaps
    end
  end
end
