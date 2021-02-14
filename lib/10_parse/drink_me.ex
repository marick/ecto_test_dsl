defmodule EctoTestDSL.Parse.Drink.Me do

  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      alias EctoTestDSL.Parse.Pnode
      alias EctoTestDSL.Run.Rnode
    end
  end
end
