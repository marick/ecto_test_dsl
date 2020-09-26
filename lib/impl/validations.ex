defmodule TransformerTestSupport.Impl.Validations do
  import FlowAssertions.Define.{Defchain,BodyParts}
  import ExUnit.Assertions
  use FlowAssertions.Ecto
  alias TransformerTestSupport.Impl
  

  @moduledoc """
  """

  defchain validate_changeset_against_example(changeset, example_name, example) do
    # try do
      if Map.has_key?(example, :categories) do
        cond do
          Enum.member?(example.categories, :valid) ->
            elaborate_assert(changeset.valid?,
              Impl.Messages.should_be_valid(example_name),
              left: changeset)
          Enum.member?(example.categories, :invalid) ->
            elaborate_refute(changeset.valid?,
              Impl.Messages.should_be_invalid(example_name),
              left: changeset)

          :else ->
            :no_checking_has_been_requested
        end
      end

      # if Map.has_key?(example, :changes),
      #   do: assert_changes(changeset, example.changes)
    #     changeset
    #     |> assert_change(Get.as_cast(test_data, descriptor, without: unchanged_fields))
    #     |> assert_no_changes(unchanged_fields)
    #     |> assert_errors(errors)
    #     check_spies(example[:because_of])
    # rescue
    #   exception in [ExUnit.AssertionError] ->
    #     new_message =
    #       """
    #       Example `#{inspect example_name}`: #{exception.message}"
    #       Changeset: 
    #         #{inspect changeset}
    #       Underlying changeset data:
    #         #{inspect changeset.data}
    #       """
    #     new = %{exception | message: new_message}
    #     reraise new, __STACKTRACE__
    # end
  end
    
  def validate_changeset(changeset, example_name, test_data) do
    example = Impl.Get.example(test_data, example_name)
    validate_changeset_against_example(changeset, example_name, example)
  end
    
end
