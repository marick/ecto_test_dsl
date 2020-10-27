defmodule TransformerTestSupport.Variants.EctoClassic do
  alias TransformerTestSupport.Build
  alias TransformerTestSupport.VariantSupport.Changeset
  import FlowAssertions.Define.BodyParts
  
  def start(opts), do: Build.start_with_variant(__MODULE__, opts)

  # ------------------- Hook functions -----------------------------------------

  def steps do
    make_changeset = fn _history, example ->
      Changeset.accept_params(example)
    end
    check_validation_changeset = fn [changeset | _], example ->
      Changeset.check_validation_changeset(changeset, example)
    end
    
    [make_changeset: make_changeset,
     check_validation_changeset: check_validation_changeset,
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

  def run_steps(example) do
    example.metadata.workflow_steps
    |> run_steps([example], example)
  end

  def run_steps([], history, _example), do: history
  def run_steps([{_step_name, function} | rest], history, example) do
    value = function.(history, example)
    run_steps(rest, [value | history], example)
  end

  # ----------------------------------------------------------------------------


  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Predefines
      alias TransformerTestSupport.Variants.EctoClassic

      def start(opts), do: EctoClassic.start(opts)
    end
  end
end
