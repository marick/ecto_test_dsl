defmodule TransformerTestSupport.Variants.Changeset do
  import FlowAssertions.Define.{Defchain,BodyParts}
#  import ExUnit.Assertions
  use FlowAssertions.Ecto
#  alias TransformerTestSupport.Impl.Get
  alias FlowAssertions.Ecto.ChangesetA

  def adjust_top_level(top_level) do
    sources = %{
      validate_params: __MODULE__,
      validation_assertions: __MODULE__,
    }

    Map.merge(top_level, %{__sources: sources})
  end

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
  
  def validate_params(%{module_under_test: module}, params) do
    module.changeset(struct(module), params)
  end

  defchain validation_assertions(changeset, example_name, example) do
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
    end
  end
  
end
