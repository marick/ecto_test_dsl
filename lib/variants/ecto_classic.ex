defmodule TransformerTestSupport.Variants.EctoClassic do
  alias TransformerTestSupport, as: T
  alias T.Build
  alias T.VariantSupport.Changeset

  import FlowAssertions.Define.BodyParts
  
  def start(opts), do: Build.start_with_variant(__MODULE__, opts)

  # ------------------- Hook functions -----------------------------------------

  def steps do
    make_changeset = fn _history, example ->
      Changeset.accept_params(example)
    end
    check_validation_changeset = fn [{:make_changeset, changeset} | _], example ->
      Changeset.check_validation_changeset(changeset, example)
    end

    insert_changeset = fn [{_name, changeset} | _], example ->
      example.metadata.repo.insert(changeset)
    end

    check_insertion = fn [{:insert_changeset, tuple} | _], example ->
      Changeset.check_insertion_result(tuple, example)
    end

    [make_changeset: make_changeset,
     check_validation_changeset: check_validation_changeset,
     insert_changeset: insert_changeset,
     check_insertion: check_insertion
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
