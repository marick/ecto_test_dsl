defmodule TransformerTestSupport.Variants.EctoClassic do
  import FlowAssertions.Define.{Defchain,BodyParts}
#  import ExUnit.Assertions
  use FlowAssertions.Ecto
  alias TransformerTestSupport.Get
  alias TransformerTestSupport.Build
  alias TransformerTestSupport.SmartGet
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

  @categories [:success, :validation_failure]

  def assert_category_hook(_, category) do
    elaborate_assert(
      category in @categories,
      "The EctoClassic variant only allows these categories: #{inspect @categories}",
      left: category
    )
  end
  
  # ----------------------------------------------------------------------------

  


  def validate_params(%{module_under_test: module} = test_data, example_name) do
    params = SmartGet.Params.get(test_data, example_name)
    module.changeset(struct(module), params)
  end

  defchain validation_assertions(changeset, test_data, example_name) do
    example = SmartGet.Example.get(test_data, example_name)

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
    for check <- SmartGet.ChangesetChecks.get(example),
      do: apply_assertion(changeset, check)
  end


  defp apply_assertion(changeset, {:__custom_changeset_check, f}),
    do: f.(changeset)

  defp apply_assertion(changeset, {check_type, arg}),
    do: apply ChangesetA, assert_name(check_type), [changeset, arg]

  defp apply_assertion(changeset, check_type),
    do: apply ChangesetA, assert_name(check_type), [changeset]

  defp assert_name(check_type),
    do: "assert_#{to_string check_type}" |> String.to_atom


  defmacro __using__(_) do
    quote do
      use TransformerTestSupport.Predefines
      alias TransformerTestSupport.Variants.EctoClassic

      def start(opts), do: EctoClassic.start(opts)
    end
  end

end
