defmodule TransformerTestSupport.Variants.EctoClassic do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.VariantSupport.Changeset

  import FlowAssertions.Define.BodyParts
  
  def start(opts), do: Build.start_with_variant(__MODULE__, opts)

  # ------------------- Hook functions -----------------------------------------

  defp make_changeset(_history, example),
    do: Changeset.accept_params(example)
  defp check_validation_changeset([{:make_changeset, changeset} | _], example),
    do: Changeset.check_validation_changeset(changeset, example)
  defp insert_changeset([{_name, changeset} | _], example),
    do: example.metadata.repo.insert(changeset)
  defp check_insertion([{:insert_changeset, tuple} | _], example), 
    do: Changeset.check_insertion_result(tuple, example)
  
  def steps do
    [make_changeset: &make_changeset/2,
     check_validation_changeset: &check_validation_changeset/2,
     insert_changeset: &insert_changeset/2,
     check_insertion: &check_insertion/2
    ]
  end

  def run_start_hook(top_level) do
    Map.put(top_level, :workflow_steps, steps())
  end

  @categories [:success, :validation_error]

  def assert_category_hook(_, category) do
    elaborate_assert(
      category in @categories,
      "The EctoClassic variant only allows these categories: #{inspect @categories}",
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
