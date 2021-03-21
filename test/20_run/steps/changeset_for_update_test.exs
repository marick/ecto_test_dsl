defmodule Run.Steps.ChangesetForUpdateTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs

  defmodule Schema do
    defstruct age: nil
  end

  test "the only result" do
    expected_api_module = Api
    expected_schema = Schema
    expected_struct = %Schema{age: 33}
    expected_params = %{"age" => "1"}

    stub_history(struct_for_update: expected_struct)
    stub(
      api_module: expected_api_module,
      schema: expected_schema,
      formatted_params: expected_params,
      changeset_for_update_with: fn ~M{api_module, schema}, given_struct, given_params ->
        assert expected_api_module == api_module
        assert expected_schema == schema
        assert expected_struct == given_struct
        assert expected_params == given_params
        :changeset_result
      end)
        
    Steps.changeset_for_update(:running, :struct_for_update)
    |> assert_equal(:changeset_result)
  end
end
