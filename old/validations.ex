defmodule TransformerTestSupport.Validations do
  use TransformerTestSupport.Drink.Me
  use TransformerTestSupport.Drink.AssertionJuice
  

  @moduledoc """
  """

  defchain validate_changeset_against_example(changeset, example_name, example) do
    adjust_assertion_message(
      fn ->
        changeset
        |> assert_validity(example_name, example)
        |> assert_changeset(example_name, example)
      end,
      fn message -> 
         """
         Example `#{inspect example_name}`: #{message}
           Changeset: #{inspect changeset}
         """
      end)
  end
    
  def validate_changeset(changeset, example_name, test_data) do
    example = SmartGet.Example.get(test_data, example_name)
    validate_changeset_against_example(changeset, example_name, example)
  end


  defchain assert_validity(changeset, example_name, example) do 
    if Map.has_key?(example, :categories) do
      cond do
        Enum.member?(example.categories, :valid) ->
          elaborate_assert(changeset.valid?,
            Messages.should_be_valid(example_name),
            left: changeset)
        Enum.member?(example.categories, :invalid) ->
          elaborate_refute(changeset.valid?,
            Messages.should_be_invalid(example_name),
            left: changeset)
          
        :else ->
          :no_checking_has_been_requested
      end
    end
  end

  defchain assert_changeset(changeset, _example_name, example) do
    if Map.has_key?(example, :changeset) do
      for {check_type, arg} <- example.changeset,
        do: apply_assertion(changeset, check_type, arg)
    end
  end

  def validate_categories(test_data, category_names, example_validator) do
    example_names = Get.all_example_names(test_data)

    test_data
    |> Get.filter_by_categories(example_names, category_names)
    |> Enum.map(example_validator)
  end

  alias FlowAssertions.Ecto.ChangesetA
  
  defp apply_assertion(changeset, check_type, true),
    do: apply ChangesetA, assert_name(check_type), [changeset]

  defp apply_assertion(changeset, check_type, arg),
    do: apply ChangesetA, assert_name(check_type), [changeset, arg]

  defp assert_name(check_type),
    do: "assert_#{to_string check_type}" |> String.to_atom
end
