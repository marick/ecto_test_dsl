defmodule EctoTestDSL.Run.RunningExample do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.AndRun
  use EctoTestDSL.Drink.Assertively
  import MockeryExtras.Getters

  @enforce_keys [:example, :history]
  defstruct [:example, :history,
             script: :none_just_testing,
             tracer: :none]

  getters :example, [
    eens: [],
    validation_changeset_checks: [],
    constraint_changeset_checks: [],
    result_fields: %{},
    result_matches: :unused,
  ]

  getters :example, :metadata, [
    :as_cast, :field_calculators, :name, :repo, :workflow_name,
    :variant, :format, :api_module, :usually_ignore,

    :insert_with, :changeset_with,
    :changeset_for_update_with, :update_with, :get_primary_key_with,
    :struct_for_update_with
  ]

  getter :original_params, for: [:example, :params]

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

  def formatted_params(running) do
    expanded_params(running)
    |> Run.Params.format(format(running))
  end

  def schema(running) do
    direct = Map.get(running.example.metadata, :schema)
    direct || api_module(running)
  end

  # ----------------------------------------------------------------------------

  def from(example, opts \\ []) do
    %RunningExample{
      example: example,
      script: Keyword.get(opts, :script, []),
      history: Keyword.get(opts, :history, History.new(example))
    }
  end
end
