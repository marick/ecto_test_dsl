defmodule EctoTestDSL.Parse.Node.Group do
  use EctoTestDSL.Drink.Me
  alias T.Parse.Node

  def handle_eens(example, default_module) do
    new_example = update_eenable(example, default_module)
    eens = accumulated_eens(new_example)

    Map.put(new_example, :eens, eens)
  end

  defp eenable_keys(example) do
    example
    |> KeywordX.filter_by_value(&Node.EENable.impl_for/1)
    |> Enum.map(fn {key, _value} -> key end)
  end

  defp update_eenable(example, default_module) do
    reducer = fn key, acc ->
      Map.update!(acc, key, &(Node.EENable.ensure_eens(&1, default_module)))
    end

    eenable_keys(example)
    |> Enum.reduce(example, reducer)
  end

  defp accumulated_eens(example) do 
    getter = fn key -> 
      Map.get(example, key) |> Node.EENable.eens
    end

    eenable_keys(example)
    |> Enum.flat_map(getter)
  end
end


