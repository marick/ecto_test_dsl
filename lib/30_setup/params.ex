defmodule TransformerTestSupport.Setup.Params do
  use TransformerTestSupport.Drink.Me
  use T.Drink.AssertionJuice
  alias T.SmartGet
    
  @moduledoc """
  """


  def get(example, previously: examples) do
    formatters = %{
      raw: &raw_format/1,
      phoenix: &phoenix_format/1
    }

    case Map.get(formatters, SmartGet.Example.format(example)) do
      nil -> 
        raise """
        `#{inspect example.format}` is not a valid format for test data params.
        Try one of these: `#{inspect Map.keys(formatters)}`
        """

      formatter ->
        Map.get(example, :params, [])
        |> resolve_field_refs(examples)
        |> Map.new
        |> formatter.()
    end
  end

  # Public for testing
  def resolve_field_refs(params, examples) do
    KeywordX.update_matching_structs(params, FieldRef,
      &(field_ref_to_field_value(&1, examples)))
  end

  defp field_ref_to_field_value(%FieldRef{} = fieldref, examples) do
    case Map.get(examples, fieldref.een) do 
      nil ->
        keys = Map.keys(examples)
        elaborate_flunk(Messages.missing_een(fieldref.een), right: keys)
      earlier ->
        Map.get(earlier, fieldref.field)
    end
  end
  
  # ----------------------------------------------------------------------------

  defp raw_format(map), do: map
  
  defp phoenix_format(map) do
    map
    |> Enum.map(fn {k,v} -> {value_to_string(k), value_to_string(v)} end)
    |> Map.new
  end

  defp value_to_string(value) when is_list(value),
    do: Enum.map(value, &to_string/1)
  defp value_to_string(value) when is_map(value),
    do: phoenix_format(value)
  defp value_to_string(value),
    do: to_string(value)
end
