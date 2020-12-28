defmodule TransformerTestSupport.Drink.Me do
  defmacro __using__(_) do
    quote do
      alias TransformerTestSupport, as: T
      import T.Nouns.EEN.Macros
      alias T.Nouns.{EEN,FieldRef}
      alias T.Parse
      alias T.Build
      alias T.SmartGet
      alias T.Messages

      alias T.{ChangesetX, EnumX, KeywordX}
    end
  end
end
