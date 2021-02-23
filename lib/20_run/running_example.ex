defmodule EctoTestDSL.Run.RunningExample do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AndRun
  use EctoTestDSL.Drink.AssertionJuice
  import T.ModuleX

  @enforce_keys [:example, :history]
  defstruct [:example, :history,
             script: :none_just_testing,
             tracer: :none]

  getters :example, [
    eens: [],
    validation_changeset_checks: [],
    constraint_changeset_checks: [],
    field_checks: %{},
    fields_like: :nothing,
  ]

  getters :example, :metadata, [
    :as_cast, :field_calculators, :name, :repo, :workflow_name,
    :variant, :format, :module_under_test, 

    :insert_with, :changeset_with,
    :changeset_for_update_with, :update_with, :get_primary_key_with,
    :struct_for_update_with
  ]

  private_getters :example, [:params]
  publicize :original_params, renames: :params

  def step_value!(~M{history}, step_name),
    do: History.fetch!(history, step_name)
  # A correct RunningExample will always match the above. If the first
  # argument does not, we are most likely mocking incorrectly.
  def step_value!(mocked, step_name) do
    elaborate_flunk("There does not seem to be a `step_value!` stub for `#{inspect step_name}`",
      left: "step_value!(#{inspect mocked}, #{inspect step_name})")
  end

  # Conveniences for history values we know will always have the same name.
  # Possibly a bad idea.
  def neighborhood(running), do: step_value!(running, :repo_setup)
  def expanded_params(running), do: step_value!(running, :params)



  # ----------------------------------------------------------------------------

  def from(example, opts \\ []) do
    %RunningExample{
      example: example,
      script: Keyword.get(opts, :script, []),
      history: Keyword.get(opts, :history, History.new(example))
    }
  end

  # ----------------------------------------------------------------------------
  def formatted_params_for_history(running, params) do
    formatters = %{
      raw: &raw_format/1,
      phoenix: &phoenix_format/1
    }

    format = mockable(__MODULE__).format(running)
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
