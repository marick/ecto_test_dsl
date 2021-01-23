defmodule TransformerTestSupport.Variants.PhoenixClassic.Insert do
  use TransformerTestSupport.Drink.Me
  alias T.Run.Steps
  alias T.Variants.PhoenixClassic.Insert, as: ThisVariant
  import T.Variants.Macros
  alias T.Parse.Start
  alias T.Parse.Callbacks
  import FlowAssertions.Define.BodyParts

  # ------------------- Step functions -----------------------------------------

  defsteps [
    :previously,
    :params,
    :changeset_from_params,
    :assert_valid_changeset,
    :refute_valid_changeset,
    :example_specific_changeset_checks,
    :as_cast_checks,
    :field_calculation_checks,
    
    :try_changeset_insertion,
    :ok_content,
    :error_content,
  ], from: Steps

  def workflows() do
    from_start_through_changeset = [
      :previously,
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
      ],
      
      constraint_error: from_start_through_validation ++ [
        [:try_changeset_insertion,           uses: [:changeset_from_params]],
        [:error_content,                     uses: [:try_changeset_insertion]],
        [:refute_valid_changeset,            uses: [:error_content]],
        [:example_specific_changeset_checks, uses: [:error_content]],
      ],
      success: from_start_through_validation ++ [
        [:try_changeset_insertion,   uses: [:changeset_from_params]],
        [:ok_content,                uses: [:try_changeset_insertion]],
      ],
    }
  end

  # ------------------- Startup -----------------------------------------

  def start(opts) do
    opts = Keyword.merge(default_start_opts(), opts)
    Start.start_with_variant(ThisVariant, opts)
  end

  defp default_start_opts, do: [
    changeset_with: &default_changeset_with/2,
    insert_with: &default_insert_with/2,
    format: :phoenix
  ]

  def default_changeset_with(module_under_test, params) do
    default_struct = struct(module_under_test)
    module_under_test.changeset(default_struct, params)
  end

  def default_insert_with(repo, changeset),
    do: repo.insert(changeset)
  
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
    optional_keys = []
    
    top_level
    |> Callbacks.validate_top_level_keys(required_keys, optional_keys)
  end

  defp assert_valid_workflow_name(workflow_name) do 
    workflows = Map.keys(workflows())
    elaborate_assert(
      workflow_name in workflows,
      "The PhoenixClassic.Insert variant only allows these workflows: #{inspect workflows}",
      left: workflow_name
    )
  end

  # ----------------------------------------------------------------------------

  IO.puts "inserted and friends should take trace arguments"

  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Predefines
      alias TransformerTestSupport.Variants.PhoenixClassic
      alias __MODULE__, as: ExamplesModule

      def start(opts) do
        PhoenixClassic.Insert.start([{:examples_module, ExamplesModule} | opts])
      end

      defmodule Tester do
        use TransformerTestSupport.Predefines.Tester
        alias T.Run.Steps

        def validation_changeset(example_name) do
          check_workflow(example_name, stop_after: :changeset_from_params)
          |> Keyword.get(:changeset_from_params)
        end

        def inserted(example_name) do
          {:ok, value} = 
            check_workflow(example_name, stop_after: :ok_content)
            |> Keyword.get(:try_changeset_insertion)
          value
        end

        def allow_asynchronous_tests(example_name),
          do: example(example_name) |> Steps.start_sandbox
        
      end
    end
  end
end
