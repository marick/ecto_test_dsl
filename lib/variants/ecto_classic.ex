defmodule TransformerTestSupport.Variants.EctoClassic do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.VariantSupport.ChangesetSupport

  import FlowAssertions.Define.BodyParts
  
  def start(opts), do: Build.start_with_variant(__MODULE__, opts)

  # ------------------- Hook functions -----------------------------------------

  defp make_changeset(_history, example),
    do: ChangesetSupport.accept_params(example)
  defp check_validation_changeset([{:make_changeset, changeset} | _], example),
    do: ChangesetSupport.check_validation_changeset(changeset, example)

  defp repo_setup(_history, example),
    do: ChangesetSupport.setup(example)

  defp insert_changeset(history, example) do
    changeset = Keyword.get(history, :make_changeset) 
    ChangesetSupport.insert(changeset, example)
  end
  
  defp check_insertion([{:insert_changeset, tuple} | _], example), 
    do: ChangesetSupport.check_insertion_result(tuple, example)
  defp check_constraint_changeset([{:insert_changeset, tuple} | _], example),
    do: ChangesetSupport.check_constraint_changeset(tuple, example)
  
  def initial_step_definitions() do
    %{
      make_changeset: &make_changeset/2,
      check_validation_changeset: &check_validation_changeset/2,
      repo_setup: &repo_setup/2,
      insert_changeset: &insert_changeset/2,
      check_insertion: &check_insertion/2
    }
  end

  @category_workflows %{
    success: [
      :make_changeset, 
      :check_validation_changeset,
      :repo_setup,
      :insert_changeset, 
      :check_insertion
    ],
    validation_error: [
      :make_changeset, 
      :check_validation_changeset, 
    ],
    validation_success: [
      :make_changeset, 
      :check_validation_changeset, 
    ],
    constraint_error: [
      :make_changeset, 
      :check_validation_changeset, 
      :repo_setup,
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

      def start(opts), do: EctoClassic.start(opts)

      defmodule Tester do
        use TransformerTestSupport.Predefines.Tester

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
        
      end
    end
  end
end
