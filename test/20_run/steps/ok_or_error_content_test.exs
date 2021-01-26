defmodule Run.Steps.OkOrErrorContentTest do
  use EctoTestDSL.Case
  use T.Drink.AndRun
  alias Run.Steps.Ecto, as: Steps
  use Mockery
  import T.RunningStubs

  setup do
    stub(workflow_name: :workflow, name: :example)
    :ok
  end

  defp run([value, step_name]) do
    stub_history(step_result: value)
    apply Steps, step_name, [:running, :step_result]
  end

  defp pass(args, expected), do: assert run(args) == expected

  test "ok_content" do 
    [{:ok, "stuff"}, :ok_content] |> pass("stuff")

    assertion_fails(~r/Example `:example`/,
      [message: ~r/Value is not an `:ok` tuple/,
       left: {:error, "stuff"}],
      fn ->
        run([{:error, "stuff"}, :ok_content])
      end)
  end

  test "error_content" do 
    [{:error, "stuff"}, :error_content] |> pass("stuff")

    assertion_fails(~r/Example `:example`/,
      [message: ~r/Value is not an `:error` tuple/,
       left: :error],
      fn ->
        run([:error, :error_content])
      end)
  end
  
end
