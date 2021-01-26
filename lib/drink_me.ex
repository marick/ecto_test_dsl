defmodule EctoTestDSL.Drink.Me do
  defmacro __using__(_) do
    quote do
      alias EctoTestDSL, as: T
      import T.Nouns.EEN.Macros
      alias T.Nouns.{EEN,FieldRef,FieldCalculator,AsCast,TestData,Example}
      alias T.{Parse,Run,Neighborhood}
      alias T.Messages
      alias T.Trace

      alias T.{ChangesetX, EnumX, KeywordX, MapX}
      import Mockery.Macro
    end
  end
end
