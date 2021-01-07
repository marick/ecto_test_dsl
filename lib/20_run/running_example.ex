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
  def name(running), do: running.example.name
  def changeset_for_validation_step(running), do:
    Map.get(running.example, :changeset_for_validation_step, [])

  def setup_instructions(running),
    do: Map.get(running.example, :setup_instructions, [])

  def neighborhood(running),
    do: Keyword.get(running.history, :previously, %{})

  def step_value!(running, step_name),
    do: History.fetch!(running.history, step_name)

  defp metadata(running), do: running.example.metadata
  def metadata(running, kind), do: metadata(running) |> Map.get(kind)

  # There are a number of older tests that don't think about history
  def expanded_params(running) do
    Keyword.get(running.history, :params, original_params(running))
  end
  defp module_under_test(running), do: metadata(running, :module_under_test)

  def accept_params(running) do
    params = expanded_params(running)
    module = module_under_test(running)
    apply metadata(running, :changeset_with), [module, params]
  end

  def workflow_name(running), do: metadata(running, :workflow_name)

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
