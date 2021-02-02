defmodule EctoTestDSL.Run.RunningExample do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AndRun
  import T.ModuleX

  @enforce_keys [:example, :history]
  defstruct [:example, :history,
             script: :none_just_testing,
             tracer: :none]

  getters :example, [
    :params_from_selecting,
    params__2: [],

    eens: [],
    validation_changeset_checks: [],
    constraint_changeset_checks: [],
    field_checks: [],
  ]

  getters :example, :metadata, [
    :as_cast, :field_calculators, :insert_with, :name, :repo, :workflow_name,
    :variant
  ]

  private_getters :example, [:params]
  publicize(:original_params, renames: :params)

  private_getters :example, :metadata, [:module_under_test]

  private_getters :history, [repo_setup: %{}]
  publicize(:neighborhood, renames: :repo_setup)

  def step_value!(running, step_name),
    do: History.fetch!(running.history, step_name)

  # Phase these out
  defp metadata(running), do: running.example.metadata
  def metadata(running, kind), do: metadata(running) |> Map.get(kind)

  # There are a number of older tests that don't think about history
  def expanded_params(running) do
    Keyword.get(running.history, :params, original_params(running))
  end

  # ----------------------------------------------------------------------------

  def from(example, opts \\ []) do
    %RunningExample{
      example: example,
      script: Keyword.get(opts, :script, []),
      history: Keyword.get(opts, :history, History.new(example))
    }
  end

  # ----------------------------------------------------------------------------

  def changeset_from_params(running) do
    params = expanded_params(running)
    module = module_under_test(running)
    apply metadata(running, :changeset_with), [module, params]
  end

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
