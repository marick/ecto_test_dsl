defmodule Run.Steps.TryParamsInsertionTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs

  test "right arguments are passed" do
    formatted_params = %{"age" => ""}

    stub(
      formatted_params: formatted_params,
      repo: SomeRepo,
      insert_with: fn repo, params ->
        assert repo == SomeRepo
        assert params == formatted_params
        {:error, "a changeset"}
      end)

    assert Steps.try_params_insertion(:running) == {:error, "a changeset"}
  end
end
