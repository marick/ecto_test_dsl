defmodule EctoTestDSL.Predefines do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias EctoTestDSL, as: T
      alias T.Impl
      use T.Parse.Exports
      import ExUnit.Assertions
      use FlowAssertions
      
      alias T.{Get,Validations}
    end
  end
end
