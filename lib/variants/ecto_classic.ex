defmodule TransformerTestSupport.Variants.EctoClassic do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.VariantSupport.ChangesetSupport
  alias T.Variants.EctoClassic, as: ThisVariant

  import FlowAssertions.Define.BodyParts
  
  def start(opts), do: Build.start_with_variant(ThisVariant, opts)

  # ------------------- Hook functions -----------------------------------------

  defp repo_setup(running) do
    ChangesetSupport.setup(running)
  end

  defp make_changeset(running) do 
    ChangesetSupport.accept_params(running)
  end
  
  defp check_validation_changeset(running) do 
    ChangesetSupport.check_validation_changeset(running, :make_changeset)
  end

  defp insert_changeset(running) do
    ChangesetSupport.insert(running, :make_changeset)
  end
  
  defp check_insertion(running) do
    ChangesetSupport.check_insertion_result(running, :insert_changeset)
  end
  
  defp check_constraint_changeset(running) do
    ChangesetSupport.check_constraint_changeset(running, :insert_changeset)
  end
  
  def initial_step_definitions() do
    %{
      make_changeset: &make_changeset/1,
      check_validation_changeset: &check_validation_changeset/1,
      repo_setup: &repo_setup/1,
      insert_changeset: &insert_changeset/1,
      check_insertion: &check_insertion/1,
      check_constraint_changeset: &check_constraint_changeset/1
    }
  end

  @category_workflows %{
    success: [
      :repo_setup,
      :make_changeset, 
      :check_validation_changeset,
      :insert_changeset, 
      :check_insertion
    ],
    validation_error: [
      :repo_setup,
      :make_changeset, 
      :check_validation_changeset, 
    ],
    validation_success: [
      :repo_setup,
      :make_changeset, 
      :check_validation_changeset, 
    ],
    constraint_error: [
      :repo_setup,
      :make_changeset, 
      :check_validation_changeset, 
      :insert_changeset, 
      :check_constraint_changeset
    ],
  }


  def run_start_hook(top_level) do
    top_level
    |> Map.put(:steps, initial_step_definitions())
    |> Map.put(:category_workflows, @category_workflows)
  end

  def assert_category_hook(_, category) do
    categories = Map.keys(@category_workflows)
    elaborate_assert(
      category in categories,
      "The EctoClassic variant only allows these categories: #{inspect categories}",
      left: category
    )
  end

  # ----------------------------------------------------------------------------


  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Predefines
      alias TransformerTestSupport.Variants.EctoClassic
      alias __MODULE__, as: ExamplesModule

      def start(opts) do
        EctoClassic.start([{:examples_module, ExamplesModule} | opts])
      end

      defmodule Tester do
        use TransformerTestSupport.Predefines.Tester
        alias T.VariantSupport.ChangesetSupport

        def validation_changeset(example_name) do
          check_workflow(example_name, stop_after: :make_changeset)
          |> Keyword.get(:make_changeset)
        end

        def inserted(example_name) do
          {:ok, value} = 
            check_workflow(example_name, stop_after: :check_insertion)
            |> Keyword.get(:insert_changeset)
          value
        end

        def allow_asynchronous_tests(example_name),
          do: example(example_name) |> ChangesetSupport.start_sandbox
        
      end
    end
  end
end
