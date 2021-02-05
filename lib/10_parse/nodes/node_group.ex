defmodule EctoTestDSL.Parse.Node.Group do
  use EctoTestDSL.Drink.Me
  use T.Drink.AssertionJuice
  alias T.Parse.Node

  def squeeze_into_map(kws) do
    reducer = fn {name, value}, acc ->
      case {Map.get(acc, name), Node.Mergeable.impl_for(value)} do
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
          Map.put(acc, name, Node.Mergeable.merge(previously, value))
      end
    end

    Enum.reduce(kws, %{}, reducer)
  end

  def parse_time_substitutions(example, previous_examples) do
    update_for_protocol(example, Node.ParseTimeSubstitutable,
      &(Node.ParseTimeSubstitutable.substitute(&1, previous_examples)))
  end

  def handle_eens(example, default_module) do
    new_example = 
      update_for_protocol(example, Node.EENable,
        &(Node.EENable.ensure_eens(&1, default_module)))
    
    eens = accumulated_eens(new_example)
    Map.put(new_example, :eens, eens)
  end

  def export(example) do
    example
    |> delete_keys_with_protocol(Node.Deletable)
    |> update_for_protocol(Node.Exportable, &Node.Exportable.export/1)
  end

  defp delete_keys_with_protocol(example, protocol), 
    do: Map.drop(example, keys_for_protocol(example, protocol))
  
  
  


  # ----------------------------------------------------------------------------

  defp keys_for_protocol(example, protocol) do 
    example
    |> KeywordX.filter_by_value(&protocol.impl_for/1)
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
      Map.get(example, key) |> Node.EENable.eens
    end

    keys_for_protocol(example, Node.EENable)
    |> Enum.flat_map(getter)
  end
end


