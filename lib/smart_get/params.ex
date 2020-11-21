defmodule TransformerTestSupport.SmartGet.Params do
  alias TransformerTestSupport.SmartGet
    
  @moduledoc """
  """


  def get(example, previously: previously) do
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
        example.params
        |> substitute_previous_values(previously)
        |> formatter.()
    end
  end

  defp substitute_previous_values(params, previously) do
    for {name, value} <- params do
      case value do
        {:__previously_reference, extended_example_name, :primary_key} ->
          {name, Map.get(previously, extended_example_name).id}
        _ ->
          {name, value}
      end
    end |> Map.new
  end
  
    
  # ----------------------------------------------------------------------------

  def raw_params(test_data, example_name),
    do: SmartGet.Example.get(test_data, example_name).params

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
