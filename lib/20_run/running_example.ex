defmodule TransformerTestSupport.Run.RunningExample do
  use TransformerTestSupport.Drink.Me
  use TransformerTestSupport.Drink.AndRun

  @enforce_keys [:example, :history]
  defstruct [:example, :history,
             script: :none_just_testing,
             tracer: :none]

  def from(example, opts \\ []) do
    %RunningExample{
      example: example,
      script: Keyword.get(opts, :script, []),
      history: Keyword.get(opts, :history, History.new(example))
    }
  end    

  def original_params(running), do: running.example.params

  def setup_instructions(running),
    do: Map.get(running.example, :setup_instructions, [])

  def neighborhood(running),
    do: Keyword.get(running.history, :previously, %{})

  def step_value!(running, step_name),
    do: History.step_value!(running.history, step_name)

  # ----------------------------------------------------------------------------
  def format_params(running, params) do
    formatters = %{
      raw: &raw_format/1,
      phoenix: &phoenix_format/1
    }

    format = running.example.metadata.format
    case Map.get(formatters, format) do
      nil -> 
        raise """
        `#{inspect format}` is not a valid format for test data params.
        Try one of these: `#{inspect Map.keys(formatters)}`
        """
      formatter ->
        formatter.(params)
    end
  end

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
