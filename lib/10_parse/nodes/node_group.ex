defmodule EctoTestDSL.Parse.Node.Group do
  use EctoTestDSL.Drink.Me
  alias T.Parse.Node

  def handle_eens(example, default_module) do
    new_example = 
      update_for_protocol(example, Node.EENAble,
        &(Node.EENable.ensure_eens(&1, default_module)))
    
    eens = accumulated_eens(new_example)
    Map.put(new_example, :eens, eens)
  end

  defp keys_for_protocol(example, protocol) do 
    example
    |> KeywordX.filter_by_value(&protocol.impl_for/1)
    |> Enum.map(fn {key, _value} -> key end)
  end

  defp update_for_protocol(example, protocol, f) do
    reducer = fn key, acc ->
      Map.update!(acc, key, f)
    end

    keys_for_protocol(example, Node.EENable)
    |> Enum.reduce(example, reducer)
  end

  defp accumulated_eens(example) do 
    getter = fn key -> 
      Map.get(example, key) |> Node.EENable.eens
    end

    keys_for_protocol(example, Node.EENable)
    |> Enum.flat_map(getter)
  end
end


