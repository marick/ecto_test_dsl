defmodule TransformerTestSupport.Variants.Changeset do
  import FlowAssertions.Define.{Defchain,BodyParts}
#  import ExUnit.Assertions
  use FlowAssertions.Ecto
  alias TransformerTestSupport.Impl.{Build,Get}
  alias FlowAssertions.Ecto.ChangesetA


  def start(opts), do: Build.start_with_variant(__MODULE__, opts)

  # ------------------- Hook functions -----------------------------------------

  def run_start_hook(top_level) do
    sources = %{
      validate_params: __MODULE__,
      validation_assertions: __MODULE__,
    }

    Map.merge(top_level, %{__sources: sources})
  end

  
  
  # ----------------------------------------------------------------------------

  

  @categories [:valid, :invalid]

  def assert_category(category) do
    elaborate_assert(
      category in @categories,
      "The Changeset variant only allows these categories: #{inspect @categories}",
      left: category
    )
  end


  def adjust_example(example, category) do
    assert_category(category)
    assertions = Map.get(example, :changeset, []) |> Enum.into([])
    Map.put(example, :changeset, [category | assertions])
  end

  def validate_params(%{module_under_test: module} = test_data, example_name) do
    params = Get.params(test_data, example_name)
    module.changeset(struct(module), params)
  end

  defchain validation_assertions(changeset, test_data, example_name) do
    example = Get.example(test_data, example_name)

    adjust_assertion_message(
      fn ->
        try_assertions(changeset, example_name, example)
      end,
      fn message ->
         """
         Example `#{inspect example_name}`: #{message}
           Changeset: #{inspect changeset}
         """
      end)
  end

  def check_everything(test_data, example_name) do
    changeset = validate_params(test_data, example_name)
    validation_assertions(changeset, test_data, example_name)
  end

  # ----------------------------------------------------------------------------


  defp try_assertions(changeset, _example_name, example) do
    if Map.has_key?(example, :changeset) do
      for check <- example.changeset,
        do: apply_assertion(changeset, check)
    end
  end

  defp apply_assertion(changeset, {check_type, arg}),
    do: apply ChangesetA, assert_name(check_type), [changeset, arg]

  defp apply_assertion(changeset, check_type),
    do: apply ChangesetA, assert_name(check_type), [changeset]

  defp assert_name(check_type),
    do: "assert_#{to_string check_type}" |> String.to_atom


  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Impl.Predefines
      alias TransformerTestSupport.Variants.Changeset

      def start(opts), do: Changeset.start(opts)
    end
  end

end
