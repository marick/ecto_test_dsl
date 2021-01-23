defmodule Run.CheckInsertionResultStep.CheckInsertionResult do
  use TransformerTestSupport.Case
  use T.Drink.AndRun
  alias Run.Steps
  use Mockery
  import T.RunningStubs

  setup do
    stub(workflow_name: :success, name: :example)
    :ok
  end

  defp run(insertion_results) do
    stub_history(try_changeset_insertion: insertion_results)
    Steps.check_insertion_result(:running, :try_changeset_insertion)
  end

  defp pass(setup), do: assert run(setup) == :uninteresting_result

  test "expecting OK structure; got it",
    do: {:ok, "...anything..."} |> pass()

  test "anything else" do
    assertion_fails(~r/Example `:example`/,
      [message: ~r/unexpected insertion failure/,
       left: {:error, "...anything..."}],
      fn ->
        run({:error, "...anything..."})
      end)
  end
end
