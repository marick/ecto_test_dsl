defmodule TransformerTestSupport.RunningExample do
  alias TransformerTestSupport, as: T
  alias T.RunningExample
  alias T.RunningExample.History
  alias T.SmartGet.Example

  @enforce_keys [:example, :history]
  defstruct [:example, :history,
             script: :none_just_testing,
             tracer: :none]

  def run(example, opts \\ []) do
    %RunningExample{
      example: example,
      script: Example.workflow_script(example, opts),
      history: History.new(example, opts)}
    |> run_steps
  end

  defp run_steps(running) do
    case running.script do
      [] ->
        running.history
      [{step_name, function} | rest] ->
        value = function.(running)

        running
        |> Map.update!(:history, &(History.add(&1, step_name, value)))
        |> Map.put(:script, rest)
        |> run_steps
    end
  end

  # ----------------------------------------------------------------------------

  def step_value!(running, step_name),
    do: History.step_value!(running.history, step_name)
end
