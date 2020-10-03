defmodule TransformerTestSupport.Impl.Get__2 do
#  import FlowAssertions.Define.BodyParts
    
  @moduledoc """
  """

  @doc """
  All data access must go through here so that the module is initialized.
  """
  def test_data(test_data_module),
    do: TransformerTestSupport__2.test_data(test_data_module)


  def example(test_data, example_name) do
    case test_data.examples[example_name] do
      nil ->
        raise "There is no example named `#{inspect example_name}`"
      retval ->
        retval
    end
  end
  
  
  def get_params(test_data_module, example_name) when is_atom(test_data_module),
    do: get_params(test_data(test_data_module), example_name)

  def get_params(test_data, example_name) do
    formatters = %{
      raw: &raw_params/2,
      phoenix: fn test_data, example_name ->
        raw_params(test_data, example_name) |> phoenix_format
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

  defp raw_params(test_data, example_name),
    do: example(test_data, example_name).params

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

  # ----------------------------------------------------------------------------
  
end
