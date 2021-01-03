defmodule TransformerTestSupport.Drink.AndRun do
  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Nouns.History
      alias TransformerTestSupport.Run.RunningExample
    end
  end
end
