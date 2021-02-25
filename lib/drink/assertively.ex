defmodule EctoTestDSL.Drink.Assertively do
  defmacro __using__(_) do
    quote do
      import ExUnit.Assertions
      use FlowAssertions
      use FlowAssertions.Ecto
      alias FlowAssertions.Ecto.ChangesetA
      import FlowAssertions.Define.{Defchain, BodyParts}
    end
  end
end
