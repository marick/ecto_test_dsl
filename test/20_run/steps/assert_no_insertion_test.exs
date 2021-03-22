defmodule Run.Steps.AssertNoInsertionTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias T.Run.Steps
  import T.RunningStubs
  
  defmodule Schema do
  end

  defmodule Repo do
  end

  setup do 
    stub(
      name: :example,
      repo: Repo,
      schema: Schema,
      existing_ids_with: fn _ ->
        [4, 12]
      end)
    :ok
  end

  test "success" do
    stub_history(existing_ids: [12, 4])
    assert Steps.assert_no_insertion(:running) == :uninteresting_result
  end

  test "failure" do
    stub_history(existing_ids: [12])
    assertion_fails(~r/Schema entries were supposed to be unchanged/,
      [ message: ~r/There were 1. Now there are 2./,
        left: [12],
        right: [4, 12]],
      fn ->
        Steps.assert_no_insertion(:running)
      end)
  end
end
