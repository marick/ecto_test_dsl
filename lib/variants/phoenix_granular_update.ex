defmodule EctoTestDSL.Variants.PhoenixGranular.Update do
  use EctoTestDSL.Drink.Me
  alias T.Run.Steps
  alias T.Variants.PhoenixGranular.Update, as: ThisVariant
  import T.Variants.Macros
  alias T.Parse.Start
  # alias T.Parse.Callbacks
  # import FlowAssertions.Define.BodyParts

  # ------------------- Step functions -----------------------------------------

  defsteps [
    # :assert_valid_changeset,
    # :refute_valid_changeset,
    # :example_specific_changeset_checks,
    # :as_cast_checks,
    # :field_calculation_checks,
  ], from: Steps.Changeset

  defsteps [
    :params_from_selecting
    # :ok_content,
    # :error_content,
  ], from: Steps.Ecto

  defsteps [
    # :repo_setup,
    # :params,
    # :changeset_from_params,
  ], from: Steps

  def workflows() do 
    %{
      success: [
        :repo_setup,
        :params_from_selecting,
      ],
    }
  end

  # ------------------- Startup -----------------------------------------

  def start(opts) do
    opts = Keyword.merge(default_start_opts(), opts)
    Start.start_with_variant(ThisVariant, opts)
  end

  defp default_start_opts, do: [
    select_with: &default_select_with/3,
    # changeset_with: &default_changeset_with/2,
    format: :phoenix
  ]

  def default_select_with(repo, queryable, example), 
    do: repo.get!(queryable, example.id)
  

  # def default_changeset_with(module_under_test, params) do
  #   default_struct = struct(module_under_test)
  #   module_under_test.changeset(default_struct, params)
  # end

  # def default_insert_with(repo, changeset),
  #   do: repo.insert(changeset)
  
  # ------------------- Hook functions -----------------------------------------

  def hook(:start, top_level, []) do 
    # assert_valid_keys(top_level)
    top_level
  end

  def hook(:workflow, top_level, [_workflow_name]) do
    # assert_valid_workflow_name(workflow_name)
    top_level
  end

  # defp assert_valid_keys(top_level) do
  #   required_keys = [:examples_module, :repo] ++ Keyword.keys(default_start_opts())
  #   optional_keys = []
    
  #   top_level
  #   |> Callbacks.validate_top_level_keys(required_keys, optional_keys)
  # end

  # defp assert_valid_workflow_name(workflow_name) do 
  #   workflows = Map.keys(workflows())
  #   elaborate_assert(
  #     workflow_name in workflows,
  #     "The PhoenixGranular.Update variant only allows these workflows: #{inspect workflows}",
  #     left: workflow_name
  #   )
  # end

  # ----------------------------------------------------------------------------

  defmacro __using__(_) do
    quote do
      use EctoTestDSL.Predefines
      alias EctoTestDSL.Variants.PhoenixGranular
      alias __MODULE__, as: ExamplesModule

      def start(opts) do
        PhoenixGranular.Update.start([{:examples_module, ExamplesModule} | opts])
      end

      defmodule Tester do
        use EctoTestDSL.Predefines.Tester
        alias T.Run.Steps

        # def validation_changeset(example_name) do
        #   check_workflow(example_name, stop_after: :changeset_from_params)
        #   |> Keyword.get(:changeset_from_params)
        # end

        # def inserted(example_name) do
        #   {:ok, value} = 
        #     check_workflow(example_name, stop_after: :ok_content)
        #     |> Keyword.get(:try_changeset_insertion)
        #   value
        # end

        # def allow_asynchronous_tests(example_name),
        #   do: example(example_name) |> Steps.start_sandbox
        
      end
    end
  end
end
