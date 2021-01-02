defmodule TransformerTestSupport.Drink.AndRun do
  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport.Run.RunningExample
      alias TransformerTestSupport.Run.RunningExample.History
      alias TransformerTestSupport.Run.RunningExample.Trace
    end
  end
end
