defmodule TransformerTestSupport.Variants.EctoClassic.Insert do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.VariantSupport.ChangesetSupport
  alias T.Variants.EctoClassic.Insert, as: ThisVariant

  import FlowAssertions.Define.BodyParts
  
  def start(opts) do
    Build.start_with_variant(ThisVariant, opts)
  end

  # ------------------- Hook functions -----------------------------------------

  defp previously(running) do
    ChangesetSupport.previously(running)
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
      previously: &previously/1,
      insert_changeset: &insert_changeset/1,
      check_insertion: &check_insertion/1,
      check_constraint_changeset: &check_constraint_changeset/1
    }
  end

  @workflows %{
    success: [
      :previously,
      :make_changeset, 
      :check_validation_changeset,
      :insert_changeset, 
      :check_insertion
    ],
    validation_error: [
      :previously,
      :make_changeset, 
      :check_validation_changeset, 
    ],
    validation_success: [
      :previously,
      :make_changeset, 
      :check_validation_changeset, 
    ],
    constraint_error: [
      :previously,
      :make_changeset, 
      :check_validation_changeset, 
      :insert_changeset, 
      :check_constraint_changeset
    ],
  }

  @required_keys [:examples_module, :repo]
  @optional_keys []

  def run_start_hook(top_level) do
    top_level
    |> Build.validate_keys_including_variant_keys(@required_keys, @optional_keys)
    |> Map.put(:steps, initial_step_definitions())
    |> Map.put(:workflows, @workflows)
  end

  def assert_workflow_hook(_, workflow) do
    workflows = Map.keys(@workflows)
    elaborate_assert(
      workflow in workflows,
      "The EctoClassic.Insert variant only allows these workflows: #{inspect workflows}",
      left: workflow
    )
  end

  # ----------------------------------------------------------------------------


  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Predefines
      alias TransformerTestSupport.Variants.EctoClassic
      alias __MODULE__, as: ExamplesModule

      def start(opts) do
        EctoClassic.Insert.start([{:examples_module, ExamplesModule} | opts])
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
