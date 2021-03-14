defmodule Run.Steps.ChangesetFromParamsTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs

  defmodule Schema do
    defstruct age: nil
  end

  test "the only result" do
    module_under_test = Schema
    formatted_params = %{"age" => "1"}

    stub(
      module_under_test: module_under_test,
      formatted_params: formatted_params,
      changeset_with: fn given_module, given_params ->
        assert module_under_test == given_module
        assert formatted_params == given_params
        :changeset_result
      end)

    Steps.changeset_from_params(:running)
    |> assert_equal(:changeset_result)
  end
end
