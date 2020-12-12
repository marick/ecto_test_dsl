defmodule TransformerTestSupport.Drink.Me do
  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport, as: T
      import T.Parse.Types.EEN.Macros
      alias T.Parse.Types
      alias T.Build
      alias T.SmartGet
    end
  end
end
