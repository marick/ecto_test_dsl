defmodule EctoTestDSL.Parse.BuildState do
  use EctoTestDSL.Drink.Me
  alias T.Parse.BuildState

  def put(map) do
    Process.put(BuildState, map)
    map
  end

  def current do
    Process.get(BuildState)
  end
end
