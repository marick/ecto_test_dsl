defmodule EctoTestDSL.Parse.All do

  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      import EctoTestDSL.Parse.TopLevel
      import EctoTestDSL.Parse.ExampleFunctions
      import EctoTestDSL.Parse.InternalFunctions
    end
  end
end
