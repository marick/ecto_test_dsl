defmodule Run.ConstraintStep.MustHaveChangesetTest do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs

  setup do
    stub(name: :example)
    :ok
  end

  defp run(insertion_results) do
    stub_history(insert_changeset: insertion_results)
    Steps.check_constraint_changeset__2(:running, :insert_changeset)
  end

  test "error structure must exist" do
    assertion_fails(~r/Example `:example`/,
      [message: ~r/expected an error tuple containing a changeset/,
       left: {:ok, "...anything..."}],
      fn ->
        run({:ok, "...anything..."})
      end)
  end
end
