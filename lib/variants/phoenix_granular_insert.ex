defmodule EctoTestDSL.Variants.PhoenixGranular.Insert do
  use EctoTestDSL.Drink.Me
  alias T.Variants.PhoenixGranular.Insert, as: ThisVariant
  alias T.Parse.Start
  alias T.Parse.Callbacks
  import FlowAssertions.Define.BodyParts
  alias T.Variants.Common.DefaultFunctions

  # ------------------- Workflows -----------------------------------------

  use T.Run.Steps

  def workflows() do
    from_start_through_changeset = [
      :repo_setup,
      :existing_ids,
      :params,
      :changeset_from_params,
    ]

    from_start_through_validation = from_start_through_changeset ++ [
      [:assert_valid_changeset,            uses: [:changeset_from_params]],
      [:example_specific_changeset_checks, uses: [:changeset_from_params]],
      [:as_cast_checks,                    uses: [:changeset_from_params]],
      [:field_calculation_checks,          uses: [:changeset_from_params]],
    ]
    
    %{
      validation_success: from_start_through_validation,
      validation_error: from_start_through_changeset ++ [
        [:refute_valid_changeset,            uses: [:changeset_from_params]],
        [:example_specific_changeset_checks, uses: [:changeset_from_params]],
        [:as_cast_checks,                    uses: [:changeset_from_params]],
        :assert_no_insertion,
      ],
      
      constraint_error: from_start_through_validation ++ [
        [:try_changeset_insertion,           uses: [:changeset_from_params]],
        [:error_content,                     uses: [:try_changeset_insertion]],
        [:refute_valid_changeset,            uses: [:error_content]],
        [:example_specific_changeset_checks, uses: [:error_content]],
        :assert_no_insertion,
      ],
      success: from_start_through_validation ++ [
        [:try_changeset_insertion,   uses: [:changeset_from_params]],
        [:ok_content,                uses: [:try_changeset_insertion]],
        [:check_results,             uses: [:ok_content]],
      ],
    }
  end

  # ------------------- Startup -----------------------------------------

  def start(opts) do
    opts = Keyword.merge(default_start_opts(), opts)
    Start.start_with_variant(ThisVariant, opts)
  end

  defp default_start_opts, do: [
    changeset_with: &DefaultFunctions.params_only_changeset/2,
    insert_with: &DefaultFunctions.plain_insert/2,
    existing_ids_with: &DefaultFunctions.existing_ids/1,
    format: :phoenix,
    usually_ignore: [],
  ]

  
  # ------------------- Hook functions -----------------------------------------

  def hook(:start, top_level, []) do 
    assert_valid_keys(top_level)
    top_level
  end

  def hook(:workflow, top_level, [workflow_name]) do
    assert_valid_workflow_name(workflow_name)
    top_level
  end

  defp assert_valid_keys(top_level) do
    required_keys = [:examples_module, :repo] ++ Keyword.keys(default_start_opts())
    optional_keys = [:schema]
    
    top_level
    |> Callbacks.validate_top_level_keys(required_keys, optional_keys)
  end

  defp assert_valid_workflow_name(workflow_name) do 
    workflows = Map.keys(workflows())
    elaborate_assert(
      workflow_name in workflows,
      "The PhoenixGranular.Insert variant only allows these workflows: #{inspect workflows}",
      left: workflow_name
    )
  end

  # ----------------------------------------------------------------------------

  IO.puts "inserted and friends should take trace arguments"

  defmacro __using__(_) do
    quote do
      use EctoTestDSL.Predefines
      alias EctoTestDSL.Variants.PhoenixGranular
      alias __MODULE__, as: ExamplesModule

      def start(opts) do
        PhoenixGranular.Insert.start([{:examples_module, ExamplesModule} | opts])
      end

      defmodule Tester do
        use EctoTestDSL.Predefines.Tester
        alias T.Run.Steps

        def validation_changeset(example_name) do
          check_workflow(example_name, stop_after: :changeset_from_params)
          |> Keyword.get(:changeset_from_params)
        end

        def inserted(example_name) do
          result =
            check_workflow(example_name)
            |> Keyword.get(:try_changeset_insertion)
          case result do
            {:ok, value} ->
              value
            _ ->
              message = """
              You asked for the result of a successful insertion,
              but the actual insertion attempt failed.
              """
              elaborate_flunk(message, [left: result])
          end
        end
      end
    end
  end
end
