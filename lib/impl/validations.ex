defmodule TransformerTestSupport.Impl.Validations do
  import FlowAssertions.Define.Defchain
  import ExUnit.Assertions
  use FlowAssertions.Ecto
  alias TransformerTestSupport.Impl
  

  @moduledoc """
  """

  defchain validate_changeset(changeset, example_name, test_data) do
    example = Impl.Get.example(test_data, example_name)

    try do 
      assert changeset.valid? == Enum.member?(example.categories, :valid)

      if Map.has_key?(example, :changes),
        do: assert_changes(changeset, example.changes)
    #     changeset
    #     |> assert_change(Get.as_cast(test_data, descriptor, without: unchanged_fields))
    #     |> assert_no_changes(unchanged_fields)
    #     |> assert_errors(errors)
    #     check_spies(example[:because_of])
    rescue
      exception in [ExUnit.AssertionError] ->
        new_message =
          """
          Example `#{inspect example_name}`: #{exception.message}"
          Changeset: 
            #{inspect changeset}
          Underlying changeset data:
            #{inspect changeset.data}
          """
        new = %{exception | message: new_message}
        reraise new, __STACKTRACE__
    end
  end
end
