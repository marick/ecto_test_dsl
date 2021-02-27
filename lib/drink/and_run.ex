defmodule EctoTestDSL.Drink.AndRun do
  defmacro __using__(_) do
    quote do
      alias EctoTestDSL.Nouns.History
      alias EctoTestDSL.Run
      alias EctoTestDSL.Run.RunningExample
      alias EctoTestDSL.Run.ChangesetAssertions
      alias EctoTestDSL.Run.Reporting
    end
  end
end
