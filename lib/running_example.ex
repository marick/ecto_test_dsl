defmodule TransformerTestSupport.RunningExample do
  alias TransformerTestSupport, as: T
  alias T.RunningExample
  alias T.SmartGet.Example

  @enforce_keys [:example, :script, :history]
  defstruct [:example, :script, :history, tracer: :none]

  def new(example, script, history) do
    %RunningExample{
      example: example,
      script: script,
      history: history}
  end

  def run(example, opts \\ []) do
    r = new(
      example,
      Example.workflow_script(example, opts),
      RunningExample.History.new(example, opts))

    run_steps(r)
  end

  defp run_steps(running) do
    case running.script do
      [] ->
        running.history
      [{step_name, function} | rest] ->
        value = function.(running.history, running.example)

        running
        |> Map.update!(:history, &(RunningExample.History.add(&1, step_name, value)))
        |> Map.put(:script, rest)
        |> run_steps
    end
  end
end
