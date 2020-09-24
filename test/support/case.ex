defmodule TransformerTestSupport.Case do
  defmacro __using__(_) do
    quote do 
      use ExUnit.Case, async: true
      use FlowAssertions
      use FlowAssertions.Ecto
    end
  end
end
