defmodule Run.Steps.ChangesetFromParamsTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs

  defmodule Schema do
    defstruct age: nil
  end

  test "the only result" do
    api_module = Schema
    formatted_params = %{"age" => "1"}

    stub(
      api_module: api_module,
      formatted_params: formatted_params,
      changeset_with: fn given_module, given_params ->
        assert api_module == given_module
        assert formatted_params == given_params
        :changeset_result
      end)

    Steps.changeset_from_params(:running)
    |> assert_equal(:changeset_result)
  end
end
