defmodule EctoTestDSL.MapX do
  import FlowAssertions.Define.BodyParts, only: [elaborate_flunk: 2]

  # This is tested indirectly
  def fetch!(map, key, on_failure) do
    case Map.get(map, key) do 
      nil ->
        keys = Map.keys(map)
        elaborate_flunk(on_failure.(key), right: keys)
      value ->
        value
    end
  end
end
