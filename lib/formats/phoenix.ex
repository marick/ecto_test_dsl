defmodule Formats.Phoenix do
  use EctoTestDSL.Drink.Me

  def format(struct) when is_struct(struct),
    do: Map.from_struct(struct) |> format

  def format(map) do 
    map
    |> Map.delete(:__meta__)
    |> Enum.map(fn {k,v} -> {value_to_string(k), value_to_string(v)} end)
    |> Map.new
  end

  defp value_to_string(value) do
    cond do
      is_list(value) ->
        Enum.map(value, &value_to_string/1)
      String.Chars.impl_for(value) ->
        to_string(value)
      is_map(value) -> 
        format(value)
      true ->
        value
    end
  end
end
