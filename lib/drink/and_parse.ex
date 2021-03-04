defmodule EctoTestDSL.Drink.AndParse do

  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias EctoTestDSL.Parse.{Pnode,BuildState,Hooks}
      alias EctoTestDSL.Run.Rnode
    end
  end
end
