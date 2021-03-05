defmodule Run.Steps.ChangesetForUpdateTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs

  defmodule Schema do
    defstruct age: nil
  end

  test "the only result" do
    module_under_test = Schema
    struct = %Schema{age: 33}
    expanded_params = %{"age" => "1"}

    stub_history(struct_for_update: struct)
    stub(
      module_under_test: module_under_test,
      expanded_params: expanded_params,
      changeset_for_update_with: fn given_module, given_struct, given_params ->
        assert module_under_test == given_module
        assert struct == given_struct
        assert expanded_params == given_params
        :changeset_result
      end)
        
    Steps.changeset_for_update(:running, :struct_for_update)
    |> assert_equal(:changeset_result)
  end
end
