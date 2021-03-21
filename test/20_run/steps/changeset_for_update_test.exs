defmodule Run.Steps.ChangesetForUpdateTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs

  defmodule Schema do
    defstruct age: nil
  end

  test "the only result" do
    api_module = Schema
    struct = %Schema{age: 33}
    formatted_params = %{"age" => "1"}

    stub_history(struct_for_update: struct)
    stub(
      api_module: api_module,
      formatted_params: formatted_params,
      changeset_for_update_with: fn given_module, given_struct, given_params ->
        assert api_module == given_module
        assert struct == given_struct
        assert formatted_params == given_params
        :changeset_result
      end)
        
    Steps.changeset_for_update(:running, :struct_for_update)
    |> assert_equal(:changeset_result)
  end
end
