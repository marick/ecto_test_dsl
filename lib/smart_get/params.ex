defmodule TransformerTestSupport.SmartGet.Params do
  alias TransformerTestSupport.SmartGet
    
  @moduledoc """
  """


  def get(example) do
    formatters = %{
      raw: &raw_format/1,
      phoenix: &phoenix_format/1
    }

    case Map.get(formatters, example.metadata.format) do
      nil -> 
        raise """
        `#{inspect example.format}` is not a valid format for test data params.
        Try one of these: `#{inspect Map.keys(formatters)}`
        """

      formatter ->
        example.params |> formatter.()
    end
  end    
    

  def get(test_data, example_name) do
    SmartGet.Example.get(test_data, example_name)
    |> get
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
