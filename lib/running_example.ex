defmodule TransformerTestSupport.RunningExample do
  alias TransformerTestSupport, as: T
  alias T.RunningExample
  alias T.SmartGet.Example

  @enforce_keys [:example, :history]
  defstruct [:example, :history, trace: :none]

  def new(example, history) do
    %RunningExample{
      example: example,
      history: history}
  end

  def run(example, opts \\ []) do
    starting_history = RunningExample.History.new(example, opts)

    Example.workflow_script(example, opts)
    |> run_steps(starting_history.data, example)
  end

  defp run_steps([], history, _example), do: history
  defp run_steps([{step_name, function} | rest], history, example) do
    value = function.(history, example)
    run_steps(rest, [{step_name, value} | history], example)
  end
end
