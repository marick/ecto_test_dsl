defmodule EctoTestDSL.Parse.Pnode.Group do
  use EctoTestDSL.Drink.Me
  use T.Drink.AndParse
  use T.Drink.Assertively

  def squeeze_into_map(kws) do
    reducer = fn {name, value}, acc ->
      case {Map.get(acc, name), Pnode.Mergeable.impl_for(value)} do
        {nil, _} ->
          Map.put(acc, name, value)

        {previously, nil} -> 
          elaborate_flunk("`#{inspect name}` may not be repeated",
            left: previously,
            right: value)

        {previously, _} ->
          elaborate_assert(previously.__struct__ == value.__struct__,
            "You've repeated `#{inspect name}`, but with incompatible values",
            left: previously, right: value)
          Map.put(acc, name, Pnode.Mergeable.merge(previously, value))
      end
    end

    Enum.reduce(kws, %{}, reducer)
  end

  def parse_time_substitutions(example, previous_examples) do
    update_for_protocol(example, Pnode.Substitutable,
      &(Pnode.Substitutable.substitute(&1, previous_examples)))
  end

  def collect_eens(example) do
    eens = accumulated_eens(example)
    Map.put(example, :eens, eens)
  end

  def export(example) do
    example
    |> delete_keys_with_protocol(Pnode.Deletable)
    |> update_for_protocol(Pnode.Exportable, &Pnode.Exportable.export/1)
  end

  defp delete_keys_with_protocol(example, protocol), 
    do: Map.drop(example, keys_for_protocol(example, protocol))
  
  
  


  # ----------------------------------------------------------------------------

  defp keys_for_protocol(example, protocol) do 
    example
    |> KeyVal.filter_by_value(&protocol.impl_for/1)
    |> Enum.map(fn {key, _value} -> key end)
  end

  defp update_for_protocol(example, protocol, f) do
    reducer = fn key, acc ->
      Map.update!(acc, key, f)
    end

    keys_for_protocol(example, protocol)
    |> Enum.reduce(example, reducer)
  end

  defp accumulated_eens(example) do 
    getter = fn key -> 
      Map.get(example, key) |> Pnode.EENable.eens
    end

    keys_for_protocol(example, Pnode.EENable)
    |> Enum.flat_map(getter)
  end
end


