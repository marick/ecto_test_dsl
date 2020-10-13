defmodule TransformerTestSupport.Impl.SmartGet.Params do
  alias TransformerTestSupport.Impl.Get
    
  @moduledoc """
  """
  
  def get(test_data_module, example_name) when is_atom(test_data_module),
    do: get(Get.test_data(test_data_module), example_name)

  def get(test_data, example_name) do
    formatters = %{
      raw: &Get.raw_params/2,
      phoenix: fn test_data, example_name ->
        Get.raw_params(test_data, example_name) |> phoenix_format
      end
    }

    case Map.get(formatters, test_data.format) do
      nil -> 
        raise """
        `#{inspect test_data.format}` is not a valid format for test data params.
        Try one of these: `#{inspect Map.keys(formatters)}`
        """

      formatter ->
        formatter.(test_data, example_name)
    end
  end

  # ----------------------------------------------------------------------------
  
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
