defmodule EctoTestDSL.Run.Steps do
  use EctoTestDSL.Drink.Me
  use EctoTestDSL.Drink.Assertively
  use EctoTestDSL.Drink.AndRun
  import Run.From
  alias Run.Rnode
  alias Run.ChangesetChecks, as: CC
  alias FlowAssertions.MapA
  use Magritte

  Module.register_attribute __MODULE__, :step, accumulate: true, persist: true

  ###################### SETUP #####################################

  @step :repo_setup
  def repo_setup(running) do
    from(running, use: [:neighborhood, :eens])
    Neighborhood.augment(neighborhood, eens)
  end

  ###################### PARAMS #####################################

  @step :params
  def params(running) do
    from(running, use: [:neighborhood, :original_params])

    params =
      original_params
      |> Rnode.Substitutable.substitute(neighborhood)

    Trace.say(params, :params)
    params
  end


  ###################### CHANGESET #####################################


  @step :changeset_from_params
  def changeset_from_params(running) do 
    from(running, use: [:formatted_params, :api_module, :changeset_with])
    changeset_with.(api_module, formatted_params)
  end

  @step :changeset_for_update
  def changeset_for_update(running, which_struct) do
    from(running,
      use: [:formatted_params, :api_module, :changeset_for_update_with])
    from_history(running, struct: which_struct)

    changeset_for_update_with.(api_module, struct, formatted_params)
  end
  # ----------------------------------------------------------------------------

  @step :assert_valid_changeset
  def assert_valid_changeset(running, which_changeset) do 
    validity_assertions(running, which_changeset,
      ChangesetAssertions.from(:valid), "a valid")
  end

  @step :refute_valid_changeset
  def refute_valid_changeset(running, which_changeset) do 
    validity_assertions(running, which_changeset,
      ChangesetAssertions.from(:invalid), "an invalid")
  end

  defp validity_assertions(running, which_changeset, assertion, error_snippet) do
    from(running, use: [:name, :workflow_name])
    from_history(running, changeset: which_changeset)
      
    message =
      "Example `#{inspect name}`: workflow `#{inspect workflow_name}` expects #{error_snippet} changeset"
    adjust_assertion_message(
      fn ->
        assertion.(changeset)
      end,
      fn _ -> message end)

    :uninteresting_result
  end

  # ----------------------------------------------------------------------------

  @step :example_specific_changeset_checks
  def example_specific_changeset_checks(running, which_changeset) do
    from(running, use: [:name])
    from_history(running, changeset: which_changeset)
    
    user_checks(running)
    |> ChangesetAssertions.from
    |> run_assertions(changeset, name)

    :uninteresting_result
  end

  # ----------------------------------------------------------------------------
  @step :as_cast_checks
  def as_cast_checks(running, which_changeset) do
    from(running, use: [:name, :as_cast, :schema])
    from_history(running, [:params, changeset: which_changeset])

    as_cast
    |> AsCast.subtract(excluded_fields(running))
    |> AsCast.assertions(schema, params)
    |> run_assertions(changeset, name)

    :uninteresting_result
  end

  @step :field_calculation_checks
  def field_calculation_checks(running, which_changeset) do
    from(running, use: [:name, :field_calculators])
    from_history(running, changeset: which_changeset)
    
    field_calculators
    |> FieldCalculator.subtract(excluded_fields(running))
    |> FieldCalculator.assertions(changeset)
    |> run_assertions(changeset, name)
    
    :uninteresting_result
  end

  # ----------------------------------------------------------------------------
  @step :user_checks
  defp user_checks(running) do
    from(running, use: [:neighborhood, :validation_changeset_checks])

    validation_changeset_checks
    |> Neighborhood.Expand.changeset_checks(neighborhood)
  end

  defp excluded_fields(running) do
    user_checks = user_checks(running)
    # as_cast checks
    CC.unique_fields(user_checks)
  end    

  defp run_assertions(assertions, changeset, name) do
    adjust_assertion_message(
      fn ->
        for a <- assertions, do: a.(changeset)
      end,
      fn message ->
        Reporting.error_message(name, message, changeset)
      end)
  end
  
  ###################### ECTO #####################################

  @step :try_changeset_insertion
  def try_changeset_insertion(running, which_changeset) do
    from(running, use: [:repo])
    from_history(running, changeset: which_changeset)    

    RunningExample.insert_with(running).(repo, changeset)
  end

  @step :try_params_insertion
  def try_params_insertion(running) do
    from(running, use: [:repo, :formatted_params, :insert_with])
    insert_with.(repo, formatted_params)
  end

  @step :primary_key
  def primary_key(running) do
    from(running, use: [:get_primary_key_with, :neighborhood])
    from_history(running, [:params])

    get_primary_key_with.(~M{neighborhood, params})
  end

  @step :struct_for_update
  def struct_for_update(running, which_primary_key) do
    from(running, use: [:struct_for_update_with, :repo, :api_module])
    from_history(running, primary_key: which_primary_key)

    ~M{repo, api_module, primary_key}
    |> Map.put(:set_hint, :struct_for_update_with)
    |> struct_for_update_with.()
  end

  @step :try_changeset_update
  def try_changeset_update(running, which_changeset) do
    from(running, use: [:repo, :update_with])
    from_history(running, changeset: which_changeset)    

    update_with.(repo, changeset)
  end

  ###################### RESULT CHECKING  #####################################

  @step :ok_content
  def ok_content(running, which_step) do
    extract_content(running, :ok_content, which_step)
  end

  @step :error_content
  def error_content(running, which_step) do
    extract_content(running, :error_content, which_step)
  end

  defp extract_content(running, extractor, which_step) do
    from(running, use: [:name])
    from_history(running, value: which_step)

    adjust_assertion_message(
      fn ->
        apply(FlowAssertions.MiscA, extractor, [value])
      end,
      Reporting.identify_example(name))
  end

  @step :check_results
  def check_results(running, which_step) do
    from(running, use: [:name, :result_fields, :result_matches])
    from_history(running, to_be_checked: which_step)

    adjust_assertion_message(fn -> 
      check_result_fields(result_fields, to_be_checked, running)
      check_against_previous_struct(result_matches, to_be_checked, running)
    end,
      Reporting.identify_example(name))

    :uninteresting_result
  end

  defp check_result_fields(result_fields, to_be_checked, running) do
    from(running, use: [:neighborhood])
    unless Enum.empty?(result_fields) do 
      expected =
        Neighborhood.Expand.values(result_fields, with: neighborhood)
      assert_fields(to_be_checked, expected)
    end
  end

  defp check_against_previous_struct(:unused, _, _), do: :ok
  defp check_against_previous_struct(fields_from, to_be_checked, running) do 
    from(running, use: [:neighborhood, :usually_ignore])
    
    reference_value = Map.get(neighborhood, fields_from.een)
    opts =
      fields_from.opts
      |> expand_exceptions(neighborhood)
      |> expand_ignoring(usually_ignore)

    MapA.assert_same_map(to_be_checked, reference_value, opts)
  end

  defp expand_exceptions(opts, neighborhood) do
    case Keyword.get(opts, :except) do
      nil ->
        opts
      kws ->
        excepts = Neighborhood.Expand.values(kws, with: neighborhood)
        Keyword.replace(opts, :except, excepts)
    end
  end

  defp expand_ignoring(opts, usually_ignore) do
    case Keyword.has_key?(opts, :comparing) do
      true ->
        # Note: if they have both `:comparing` and `:ignoring`, fine.
        # `assert_same_map` will do the complaining.
        opts

      false -> 
        {local_ignoring, _rest} = Keyword.pop(opts, :ignoring, [])
        Keyword.put(opts, :ignoring, local_ignoring ++ usually_ignore)
    end
  end


  defmacro __using__(_) do
    step_module = __MODULE__
    for step_name <- @step do
      quote do
        def unquote(step_name)(running, rest_args) do
          args = [running | rest_args]
          apply(unquote(step_module), unquote(step_name), args)
        end
      end
    end
  end
end
